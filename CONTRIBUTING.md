# Contributing

## Developing

1. Fork the repository on GitHub
2. Create your feature branch (`git checkout -b feature/awesomeness`)
3. Create your changes.
   * Add test cases in `spec/`. It's best if you first write a failing
     test case, commit it, and then fix it in next commit - this makes
     the whole change easier to review.
   * Document your changes.
4. Commit your changes (`git commit -am 'Add more awesomeness'`)
5. Push to the branch (`git push -u origin feature/awesomeness`)
6. Create new Pull Request on GitHub

## Testing

### Install what's needed

Make sure you have [http://gembundler.com/](Gem Bundler) version 1.3
or greater installed.  If in doubt, just use [http://rvm.io/](RVM) or
[http://rbenv.org/](rbenv).

    $ gem install bundler

Clone the project:

    $ git clone git://github.com/3ofcoins/knife-briefcase.git

Then, run:

    $ cd knife-briefcase
    $ bundle install
    
Bundler will install all the needed gems and their dependencies.

### Running tests

    $ bundle exec thor spec
    
To generate test coverage report, tell it to Thor
    
    $ bundle exec thor spec --coverage
