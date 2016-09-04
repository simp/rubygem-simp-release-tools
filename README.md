# Simp::Release::Tools


* [Installation](#installation)
	* [OS Prerequisites](#os-prerequisites)
* [Usage](#usage)
	* [`package`](#package)
		* [`package record`](#package-record)
		* [`package changelog`](#package-changelog)
* [Development](#development)
* [Contributing](#contributing)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simp-release-tools'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simp-release-tools

### OS Prerequisites

The `package changelog` command relies on the command-line executable **rpmdev-vercmp**.  On EL/Fedora systems, this is provided by the `rpmdevtools` package.  To install these tools:

```bash
# From EL6/EL7
sudo yum install -y rpmdevtools

# From Fedora
sudo dnf install -y rpmdevtools
```


## Usage

### `package`

#### `package record`
Recording an RPM manifest after building an ISO from [simp-core](https://github.com/simp/simp-core):

```bash
simp-release package record simp-core/SIMP_ISO_STAGING/CentOS6.8-x86_64/
```
Recording RPM manifest from a mounted ISO

```bash
simp-release package record /var/run/media/username/SIMP-4.2.0-2/
```


#### `package changelog`

Generating a changelog RPM Updates table using two recorded RPM manifests:

```bash
simp-release package changelog -S -f out-5.1.X.rst \
   ISO_RPMs_VDD_for_SIMP-5.1.0-3.yaml ISO_RPMs_VDD_for_SIMP-5.1.0-4.Alpha_20160902-1230.yaml

```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/op-ct/simp-release-tools.

