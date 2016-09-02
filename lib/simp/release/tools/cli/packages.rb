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
    puts 'TODO list file!'
    raise NotImplementedError
  end

  desc '`changelog OLDFILE NEWFILE`', 'describe package diff'
  def changelog
    puts 'TODO changelog!'
    raise NotImplementedError
  end

  private
  def packages
    @packages ||= Simp::Release::Tools::Packages.new
  end
end

if __FILE__ == $0
  Simp::Release::Tools::CLI::Packages.start( ARGV )
end
