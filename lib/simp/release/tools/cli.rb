require 'thor'
require 'simp/release/tools'
require 'simp/release/tools/cli/packages'

module Simp; end
module Simp::Release; end
module Simp::Release::Tools; end

class Simp::Release::Tools::Cli < Thor
  desc 'packages COMMAND', 'Package info for Changelogs'
  long_desc <<-EOF
    record, list, or delta ISO RPMs for changelog.
  EOF
  subcommand 'packages', Simp::Release::Tools::CLI::Packages
end

if __FILE__ == $0
  Simp::Release::Tools::Cli.start( ARGV )
end
