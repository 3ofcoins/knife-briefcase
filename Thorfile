$:.push File.expand_path('../lib', __FILE__)
require 'rubygems'

require 'bundler/setup'

require 'rake/testtask'
require 'thor/rake_compat'

class Default < Thor
  class Gem < Thor
    namespace :gem

    include Thor::RakeCompat
    Bundler::GemHelper.install_tasks

    desc "build", "Build knife-briefcase-#{KnifeBriefcase::VERSION}.gem into the pkg directory"
    def build
      Rake::Task["build"].execute
    end

    desc "release", "Create tag v#{KnifeBriefcase::VERSION} and build and push knife-briefcase-#{KnifeBriefcase::VERSION}.gem to Rubygems"
    def release
      Rake::Task["release"].execute
    end

    desc "install", "Build and install knife-briefcase-#{KnifeBriefcase::VERSION}.gem into system gems"
    def install
      Rake::Task["install"].execute
    end
  end

  class Test < Thor
    namespace :test
    default_command :all

    include Thor::RakeCompat

    Rake::TestTask.new :spec do |task|
      task.libs << 'spec'
      task.test_files = FileList['spec/**/*_spec.rb']
    end

    desc 'spec', 'Run specs'
    def spec
      Rake::Task['spec'].execute
    end

    desc 'all', 'Run all tests'
    def all
      invoke(:spec)
    end

    desc 'ci', 'Run all tests for continuous integration'
    def ci
      ENV['CI'] = 'true'
      invoke(:all)
    end
  end
end

