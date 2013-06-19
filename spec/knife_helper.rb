# Modified from: https://github.com/jkeiser/knife-essentials/blob/master/spec/support/knife_support.rb

require 'logger'
require 'pathname'
require 'shellwords'

require 'chef_zero/server'
require 'chef/application/knife'
require 'chef/config'
require 'chef/knife'
require 'chef/log'

module KnifeBriefcase
  module Spec
    module KnifeHelper
      extend MiniTest::Spec::DSL

      class << self
        def chef_zero_server?
          !!@chef_zero_server
        end

        def chef_zero_server
          @chef_zero_server ||= start_chef_zero_server!
        end

        def chef_zero_port
          @chef_zero_port ||= chef_zero_server.
            server.
            instance_variable_get(:@ios).
            find { |io| io.class == TCPServer }.
            addr[1]
        end

        private

        def start_chef_zero_server!
          @chef_zero_server = @chef_zero_port = nil
          server = ChefZero::Server.new(:port => 0)
          server.start_background
          server
        end
      end

      DEBUG = !!ENV['DEBUG']

      before do
        if ::KnifeBriefcase::Spec::KnifeHelper.chef_zero_server?
          ::KnifeBriefcase::Spec::KnifeHelper.chef_zero_server.clear_data
        end
        @chef_configuration = Chef::Config.configuration.dup
      end

      after do
        Chef::Config.configuration = @chef_configuration
      end

      def knife_config(&block)
        Chef::Config.instance_eval(&block)
      end

      def chef_server_url
        "http://127.0.0.1:#{KnifeHelper::chef_zero_port}/"
      end

      attr_reader :knife_stdout, :knife_stderr
      attr_accessor :knife_stdin

      def knife(*args, &block)
        args = Shellwords.split(args.first) if args.length == 1
        Dir.mktmpdir('checksums') do |checksums_cache_dir|
          Chef::Config[:cache_options] = {
            :path => checksums_cache_dir,
            :skip_expires => true
          }

          # This is Chef::Knife.run without load_commands--we'll load stuff
          # ourselves, thank you very much
          stdout = StringIO.new
          stderr = StringIO.new
          stdin = knife_stdin ? StringIO.new(knife_stdin) : STDIN
          old_loggers = Chef::Log.loggers
          old_log_level = Chef::Log.level
          begin
            puts "knife: #{args.join(' ')}" if DEBUG
            subcommand_class = Chef::Knife.subcommand_class_from(args)
            subcommand_class.options = Chef::Application::Knife.options.merge(subcommand_class.options)
            subcommand_class.load_deps
            instance = subcommand_class.new(args)

            # Capture stdout/stderr
            instance.ui = Chef::Knife::UI.new(stdout, stderr, stdin, instance.config)

            # Don't print stuff
            Chef::Config[:verbosity] = ( DEBUG ? 2 : 0 )
            instance.config[:config_file] = Pathname.new(__FILE__).dirname.join('fixtures', 'knife.rb').to_s
            instance.config[:chef_server_url] = chef_server_url


            # Configure chef with a (mostly) blank knife.rb
            # We set a global and then mutate it in our stub knife.rb so we can be
            # extra sure that we're not loading someone's real knife.rb and then
            # running test scenarios against a real chef server. If things don't
            # smell right, abort.

            $__KNIFE_INTEGRATION_FAILSAFE_CHECK = "ole"
            instance.configure_chef

            unless $__KNIFE_INTEGRATION_FAILSAFE_CHECK == "ole ole"
              raise Exception, "Potential misconfiguration of integration tests detected. Aborting test."
            end
            logger = Logger.new(stderr)
            logger.formatter = proc { |severity, datetime, progname, msg| "#{severity}: #{msg}\n" }
            Chef::Log.use_log_devices([logger])
            Chef::Log.level = ( DEBUG ? :debug : :warn )
            Chef::Log::Formatter.show_time = false

            instance.run

            exit_code = 0

            # This is how rspec catches exit()
          rescue SystemExit => e
            exit_code = e.status
          ensure
            Chef::Log.use_log_devices(old_loggers)
            Chef::Log.level = old_log_level
          end


          @knife_stdout = stdout.string
          @knife_stderr = stderr.string

          puts "STDOUT:\n#{knife_stdout}\n\nSTDERR:\n#{knife_stderr}" if DEBUG
          exit_code
        end
      end
    end
  end
end
