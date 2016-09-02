require 'thor'
require 'simp/release/tools'

module Simp; end
module Simp::Release; end
module Simp::Release::Tools; end

module Simp::Release::Tools::CLI; end
class Simp::Release::Tools::CLI::Packages < Thor
  desc 'list FILE', 'list packages'
  long_desc <<-EOF
  `list` will list all packages from an archive YAML file.
  EOF

  desc '`record FILE [PATH_TO_SIMP_CORE]`', 'record packages information for this release'
  def record
    puts 'record!'
  end

  desc '`list FILE`', 'list packages in ISO packages file'
  def list
    puts 'list file!'
  end

  desc '`changelog OLDFILE NEWFILE`', 'describe package diff'
  def changelog
    puts 'changelog!'
  end
end

class Simp::Release::Tools::Cli < Thor
  desc 'packages COMMAND', 'Package info for Changelogs'
  long_desc <<-EOF
    record, list, or delta ISO RPMs for changelog.
  EOF
  subcommand 'packages', Simp::Release::Tools::CLI::Packages
end


