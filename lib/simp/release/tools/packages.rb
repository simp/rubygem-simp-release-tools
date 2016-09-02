require 'simp/rpm'

require 'yaml'
require 'find'
require 'pathname'
require 'pry' # FIXME: remove before release

module Simp::Release::Tools
  class SimpIsoPathError < RuntimeError; end

  class Simp::Release::Tools::Packages
    include Simp
    # type = :simp_core_root or :iso
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

        rpm_dirs[dir] ||= {}
        rpm_dirs[dir][info[:name]] ||= {}
        rpm_dirs[dir][info[:name]][file] = info.merge({:file=>file,:dir=>dir})
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
