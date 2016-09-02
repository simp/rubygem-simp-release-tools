require 'thor'
require 'simp/release/tools/packages'

module Simp::Release::Tools::CLI; end
class Simp::Release::Tools::CLI::Packages < Thor
  desc 'list FILE', 'list packages'
  long_desc <<-EOF
  `list` will list all packages from an archive YAML file.
  EOF

  desc '`record [PATH] [OUTFILE]`',
       'record packages information for this release'
  def record(path=Dir.pwd, outfile=nil)
    packages.record(path,outfile)
  end

  desc '`list FILE`', 'list packages in ISO packages file'
  def list
    raise NotImplementedError, 'TODO list file!'
  end

  desc '`changelog OLDFILE NEWFILE`', 'describe package diff'
  method_option :use_packages_dir,
                :default => false,
                :desc => 'Include RPMs under the Packages/ dir',
                :type => :boolean,
                :aliases => '-P'
  method_option :use_simp_dirs,
                :lazy_default => true,
                :desc => 'Include RPMs under the SIMP/* dirs',
                :type => :boolean,
                :aliases => '-S'
  method_option :use_other_dirs,
                :default => false,
                :desc => 'Include RPMs under any other dirs',
                :type => :boolean,
                :aliases => '-O'
  method_option :out_file,
                :desc => 'file path for an RST file',
                :aliases => '-f',
                :type => :string
  def changelog(old_file, new_file)
    root_paths = []
    root_paths << :packages_dir if options[:use_packages_dir]
    root_paths << :simp_dirs    if options[:use_simp_dirs]
    root_paths << :other_dirs   if options[:use_other_dirs]
    packages.changelog(old_file, new_file, root_paths, options[:out_file])
  end

  private
  def packages
    @packages ||= Simp::Release::Tools::Packages.new
  end
end

if __FILE__ == $0
  Simp::Release::Tools::CLI::Packages.start( ARGV )
end
