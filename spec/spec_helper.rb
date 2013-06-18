require 'rubygems'
require 'bundler/setup'

require 'pathname'

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'
require 'wrong'

Wrong.config.alias_assert :expect, override: true

module KnifeBriefcase
  module Spec
    module WrongHelper
      include Wrong::Assert
      include Wrong::Helpers

      def increment_assertion_count
        self.assertions += 1
      end
    end
  end
end

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
  SimpleCov.command_name 'rake spec'
end

FIXTURES = Pathname.new(__FILE__).dirname.join('fixtures')

ENV['GNUPGHOME'] = FIXTURES.join('gnupg').to_s

require 'knife_helper'

require 'gpgme'
require 'ridley'

class MiniTest::Spec
  include KnifeBriefcase::Spec::KnifeHelper
  include KnifeBriefcase::Spec::WrongHelper

  let(:ridley) do
    Ridley.new :server_url => chef_server_url,
               :client_name => 'anything',
               :client_key => FIXTURES.join('briefcase.pem').to_s
  end

  let(:crypto) { GPGME::Crypto.new }

  def with_gnupg_home(variant)
    orig_gnupg_home = ENV['GNUPGHOME']
    ENV['GNUPGHOME'] = FIXTURES.join("gnupg.#{variant}").to_s
    yield
  ensure
    ENV['GNUPGHOME'] = orig_gnupg_home
  end
end

require "knife-briefcase"
