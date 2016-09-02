# Simp::Release::Tools

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/simp/release/tools`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

```bash
# recording RPM manifest after building an ISO from [simp-core](https://github.com/simp/simp-core)
simp-release package record simp-core/SIMP_ISO_STAGING/CentOS6.8-x86_64/

# recording RPM manifest from a mounted ISO
simp-release package record /var/run/media/username/SIMP-4.2.0-3.Alpha

```

This relies on the command-line executable **rpmdev-vercmp**.  On EL/Fedora systems, this is provided by the `rpmdevtools` package.  To install:

```bash
# From EL6/EL7
sudo yum install -y rpmdevtools

# From Fedora
sudo dnf install -y rpmdevtools
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simp-release-tools'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simp-release-tools

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/simp-release-tools.

