# Knife Briefcase

This gem is [Knife](http://docs.opscode.com/knife.html) plugin for
[Opscode Chef](http://www.opscode.com/chef/) that stores GPG-encrypted
content for people in chef server's data bag.

Its intended use is to share infrastructure-related secrets (such as
encrypted data bag secret files, SSL private keys, passwords, etc.)
among the infrastructure team.

This may or may not work nicely with
[git-annex](http://git-annex.branchable.com/) via
[_hook_ special remote](http://git-annex.branchable.com/special_remotes/hook/).

## Installation

Add this line to your Chef repository's Gemfile:

    gem 'knife-briefcase', :git => git://github.com/3ofcoins/knife-briefcase/

Or install it yourself:

    $ gem build knife-briefcase.gemspec
    $ gem install knife-briefcase*.gem

## Usage

`knife briefcase put NAME [FILE]` -- encrypts and signs named `FILE`
or stdin, and saves it in the data bag with ID `NAME`.

`knife briefcase get NAME [FILE]` -- gets `NAME` from the data bag,
checks signature, decrypts, and shows the contents on standard output,
or saves it to `FILE` if provided.

`knife briefcase list` -- lists encrypted items in the data bag.

`knife briefcase delete NAME [NAME [...]]` -- deletes listed `NAME`s
from the data bag.

> **TODO: it may be good to refuse to delete files that the user is
> unable to encrypt.** User is able to delete them anyway, using
> `knife data bag delete`, but it shouldn't be allowed via `knife
> briefcase` command.

`knife briefcase reload [NAME [NAME [...]]]` -- downloads and decrypts
listed items, re-encrypts and re-signs them, and saves the
re-encrypted content back. If no names are provided, all the items are
re-encrypted. This should be called when briefcase holders list is
changed, to allow added user to decrypt bag - or to prevent further
access by removed user.

## Configuration

Following `knife.rb` settings are used:

 - `briefcase_holders` -- array of e-mail addresses that will be GPG
   recipients of the data
 - `briefcase_signers` -- e-mail address (or array of e-mail
   addresses) that will be used to sign encrypted content
 - `briefcase_data_bag` -- name of the data bag that will be used by
   default to hold encrypted content. If not provided, `briefcase`
   data bag will be used. The data bag name can be overriden on
   command line.

### Example configuration

```ruby
briefcase_signers `git config --get user.email`.strip
briefcase_holders [
  'alice@myproject.com',
  'bob@myproject.com',
  'claire@myproject.com',
  'dave@myproject.com',
  'erin@myproject.com' ]
```

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file
