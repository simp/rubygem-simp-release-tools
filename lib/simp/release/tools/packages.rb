require 'simp/rpm'

require 'yaml'
require 'find'
require 'pathname'
require 'deep_merge'
require 'pry' # FIXME: remove before release

module Simp::Release::Tools
  class SimpIsoPathError < RuntimeError; end

  class Simp::Release::Tools::Packages
    include Simp


    def munge_rpm_dirs_hash( hash, root_paths )
      rpm_dirs = {}
      if root_paths.include? :packages_dir
        rpm_dirs.merge!(hash[:rpm_dirs]['Packages'])
      end

      if root_paths.include? :other_dirs
        simp_hashes = hash[:rpm_dirs].reject{|k,v| k =~ %r{^(SIMP/.*|Packages)$}}.values
        simp_hashes.each{|h| rpm_dirs.deep_merge!(h)}
      end

      if root_paths.include? :simp_dirs
        simp_hashes = hash[:rpm_dirs].select{|k,v| k =~ %r(^SIMP/.*$)}.values
        simp_hashes.each{|h| rpm_dirs.deep_merge!(h)}
      end

      rpm_dirs
    end

    # root_paths can be 1 or both elements of [:packages_dir, :simp_dirs]
    def changelog(old_file, new_file, root_paths=[], out_file=nil)

      raise ArgumentError, 'Cannot accept empty root_paths' if root_paths.empty?
      max_items = 99999999

      old_hash = YAML.load File.read(old_file)
      new_hash = YAML.load File.read(new_file)

      old_rpm_dirs = munge_rpm_dirs_hash( old_hash, root_paths )
      new_rpm_dirs = munge_rpm_dirs_hash( new_hash, root_paths )

      altered_rpms      = {}

      removed_rpm_names = old_rpm_dirs.keys - new_rpm_dirs.keys
      removed_rpms      = old_rpm_dirs.select{|k,v| removed_rpm_names.include? k }
      removed_rpms.each{|a,b| b.map{|k,v| v[:status] = :removed; [k,v] }}
      altered_rpms.deep_merge!(removed_rpms)

      added_rpm_names   = new_rpm_dirs.keys - old_rpm_dirs.keys
      added_rpms        = new_rpm_dirs.select{|k,v| added_rpm_names.include? k }
      added_rpms.each{|a,b| b.map{|k,v| v[:status] = :added; [k,v] }}
      altered_rpms.deep_merge!(added_rpms)

      upgraded_rpms     = {}
      common_rpm_names = (old_rpm_dirs.keys & new_rpm_dirs.keys)

      ###added_rpms_archs_only   = {}
      ###removed_rpms_archs_only = {}

iii=0
      common_rpm_names.each do |name|
iii+=1
        # Compare all the versions/arch of a given package
        # scenarios:
        #   - [X] removed archs
        #   - [X] added archs
        #   - [.] same archs
        #   - [.] for each common arch:
        #     - [ ] identify upgrades
        old = {}
        new = {}
        old[:pkgs] = old_rpm_dirs[name].values
        new[:pkgs] = new_rpm_dirs[name].values

        # To prepare to compare archs,
        # re-key the hashes to compare filenames with versions removed
        old[:pkg_files_nover] = Hash[ old[:pkgs].map{|x| [clip_ver(x), x] } ]
        new[:pkg_files_nover] = Hash[ new[:pkgs].map{|x| [clip_ver(x), x] } ]

        added_archs = new[:pkg_files_nover].keys - old[:pkg_files_nover].keys
        added_archs.each do |x|
          pkg = new[:pkg_files_nover][x]
          pkg[:status]       = :added
          pkg[:extra_status] = :arch_only
          added_rpms.deep_merge!({pkg[:name] => {pkg[:file] => pkg}})
          altered_rpms.deep_merge!({pkg[:name] => {pkg[:file] => pkg}})
          ###added_rpms_archs_only.merge!({pkg[:name] => pkg})
        end

        removed_archs = old[:pkg_files_nover].keys - new[:pkg_files_nover].keys
        removed_archs.each do |x|
          pkg = old[:pkg_files_nover][x]
          pkg[:status]       = :removed
          pkg[:extra_status] = :arch_only
          removed_rpms.deep_merge!({pkg[:name] => {pkg[:file] => pkg}})
          altered_rpms.deep_merge!({pkg[:name] => {pkg[:file] => pkg}})
          ###removed_rpms_archs_only.merge!({pkg[:name] => pkg})
        end

        common_archs = old[:pkg_files_nover].keys & new[:pkg_files_nover].keys
        common_archs.each do |x|
          o = old[:pkgs].select{|p| clip_ver(p) == x}.first
          n = new[:pkgs].select{|p| clip_ver(p) == x}.first
          op = %x(rpmdev-vercmp #{n[:full_version]} #{o[:full_version]}).split(' ')[1]
          if op == '>'
            n[:status]        = :upgraded
            n[:upgraded_from] = o
            upgraded_rpms.deep_merge!({n[:name] => {n[:file] => n}})
            altered_rpms.deep_merge!({n[:name] => {n[:file] => n}})
          end
        end
        break if iii > max_items
      end


# ----- new method: formatting
      rows = []

      altered_rpms.keys.sort.each do |rpm_name|
        pkgs = altered_rpms[rpm_name].values
        if ( pkgs.map{|v| v[:full_version] }.uniq.size == 1 &&
             pkgs.map{|v| v[:status] }.uniq.size == 1 &&
             pkgs.map{|v| v[:extra_status] }.uniq.size == 1 )
          _pkgs = [ pkgs.first ]
        else
          _pkgs = pkgs
        end
        _pkgs.each do |pkg|
          name = pkg[:name]
          if pkg.key? :extra_status
            if pkg[:extra_status] == :arch_only
              name += " [#{pkg[:file].sub(/.*\.([^.]+)\.rpm/, '\1')}]"
            else
              name += " [#{pkg[:extra_status].to_s}]"
            end
          end

          if pkg[:status] == :upgraded
            o = clip_el(pkg[:upgraded_from][:full_version])
            n = clip_el(pkg[:full_version])
            if o == n
              o = pkg[:upgraded_from][:full_version]
              n = pkg[:full_version]
            end
            row = [ name, o, n ]
          elsif pkg[:status] == :added
            # TODO: handle arch_only
            row = [ name, 'N/A', clip_el(pkg[:full_version]), ]
          elsif pkg[:status] == :removed
            # TODO: handle arch_only
            row = [ name,  clip_el(pkg[:full_version]), 'N/A']

          else
            row = [ rpm_name, pkg[:status].to_s, pkg[:status].to_s ]
          end
          rows << (row )
        end
      end


      padding = 2
      max_name_size = rows.map{|x|x[0].size}.max + padding
      ov_name_size =  rows.map{|x|x[1].size}.max + padding
      nv_name_size =  rows.map{|x|x[2].size}.max + padding
      table = ''
      table_row = '+' + '-'*max_name_size + '+' + '-'*ov_name_size + '+' + '-'*nv_name_size + '+' "\n"
      table += table_row
      table += "| #{'Package'.ljust(max_name_size-1)}"
      table += "| #{'Old Version'.ljust(ov_name_size-1)}"
      table += "| #{'New Version'.ljust(nv_name_size-1)}|\n"
      table += table_row.gsub('-','=')

      rows.each do |row|
        table += "| #{row[0].ljust(max_name_size-1)}"
        table += "| #{row[1].ljust(ov_name_size-1)}"
        table += "| #{row[2].ljust(nv_name_size-1)}"
        table += "|\n"
        table += table_row
      end
      puts table
      if out_file
        puts "-- writing to '#{out_file}'"
        File.open( out_file, 'w' ){ |f| f.puts table }
        puts "-- finished writing to '#{out_file}'"
      end


    end

    def clip_el(s)
      s.sub(/\.el\d+(_\d+(\.\d+))?(\.centos)?$/,'')
      s.sub(/\.el\d+((_|\.)\d+(\.\d+)?)?(\.centos)?$/,'')
    end

    def clip_ver( rpm_info )
      rpm_info[:file].sub(rpm_info[:full_version],'')
    end

    def record(root_path,out_file)
      unless (
        File.directory?(File.join(root_path,'SIMP')) &&
        File.directory?(File.join(root_path,'Packages'))
      )
        raise SimpIsoPathError,
              "'#{root_path}' is not a SIMP ISO root directory"
      end

      simp_pkglist_path = Dir[File.join(root_path,'*-simp_pkglist.txt')].first
      simp_pkglist_txt  = File.read(simp_pkglist_path)
      simp_iso_date     = File.stat(simp_pkglist_path).mtime.strftime('%Y%m%d-%H%M')

      rpm_files = []
      Find.find(root_path).each do |path|
        rpm_files << path if path =~ /\.rpm$/
      end

      abs_root_path = Pathname.new(root_path)
      rpm_dirs = {}
      rpm_dirs2 = {}
      rpm_files.each do |path|
        _path = Pathname.new(path).relative_path_from(abs_root_path)
        info = RPM.get_info path
        dir  = File.dirname  _path
        file = File.basename _path
        extra_info = {:file=>file,:dir=>dir}
###        extra_info[:file_no_version] = file.sub( info[:full_version], '' )
###        extra_info[:file_no_arch] =  file.sub( /^(.*\.)[^.]+\.rpm$/, '\1.rpm' )

        rpm_dirs[dir] ||= {}
        rpm_dirs[dir][info[:name]] ||= {}
        rpm_dirs[dir][info[:name]][file] = info.merge( extra_info )
        rpm_dirs2[dir] ||= {}
        rpm_dirs2[dir][file] = info.merge({:file=>file,:dir=>dir})
      end

      # sanity check for duplicate packages
      dirs = rpm_dirs.keys

      out_hash = {}
      out_hash[:simp_iso_date]     = simp_iso_date
      out_hash[:simp_pkglist_path] = simp_pkglist_path
      out_hash[:rpm_dirs]          = rpm_dirs
      out_hash[:rpm_dirs2]         = rpm_dirs2
      out_hash[:simp_pkglist_txt]  = simp_pkglist_txt

      out_file ||= "ISO_RPMs_VDD_for_#{File.basename(root_path)}_#{simp_iso_date}.yaml"
      File.open(out_file,'w') do |file|
        file.write out_hash.to_yaml
      end
      puts "== RPMs recorded to '#{out_file}'"
    end
  end
end
