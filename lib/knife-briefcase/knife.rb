require 'chef/knife'

module KnifeBriefcase
  class Knife < Chef::Knife
    def self.deps
      super do
        require 'chef/data_bag'
        require 'chef/data_bag_item'
        require 'gpgme'
        require 'highline'
        yield if block_given?
      end
    end

    def self.inherited(c)
      super

      # Ensure we always get to do our includes, whether subclass calls deps or not
      c.deps() {}
      c.options.merge!(options)
    end

    category 'briefcase'

    option :data_bag,
           :long => '--data-bag',
           :description => 'Name of the data bag'

    def data_bag_name
      config[:data_bag] || Chef::Config[:briefcase_data_bag] || 'briefcase'
    end

    def signers
      Chef::Config[:briefcase_signers]
    end

    def recipients
      Chef::Config[:briefcase_holders]
    end

    def item_name
      @name_args.first
    end

    def highline
      super
    rescue NameError
      @highline ||= HighLine.new
    end

    def file
      rv = @name_args[1]
      rv == '-' ? nil : rv
    end

    private

    def crypto
      @crypto ||= GPGME::Crypto.new :armor => true, :passphrase_callback => method(:gpgme_passfunc)
    end

    def gpgme_passfunc(hook, uid_hint, passphrase_info, prev_was_bad, fd)
      pass = highline.ask("GPG passphrase for #{uid_hint}: ") { |q| q.echo = '.' }
      io = IO.for_fd(fd, 'w')
      io.write "#{pass}\n"
      io.flush
    end
  end
end
