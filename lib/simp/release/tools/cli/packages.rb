require 'thor'
require 'simp/release/tools'

module Simp::Release::Tools::CLI; end
class Simp::Release::Tools::CLI::Packages < Thor
  desc 'list FILE', 'list packages'
  long_desc <<-EOF
  `list` will list all packages from an archive YAML file.
  EOF

  desc '`record [FILE] [PATH_TO_SIMP_CORE]`',
       'record packages information for this release'
  def record(
     file=File.expand_path( 'release_rpms.yaml', Dir.pwd ),
     path=Dir.pwd
  )
    puts 'TODO record!'
  end

  desc '`list FILE`', 'list packages in ISO packages file'
  def list
    puts 'TODO list file!'
  end

  desc '`changelog OLDFILE NEWFILE`', 'describe package diff'
  def changelog
    puts 'TODO changelog!'
  end
end

if __FILE__ == $0
  Simp::Release::Tools::CLI::Packages.start( ARGV )
end
