require 'spec_helper'

require 'chef/knife/briefcase_reload'

describe Chef::Knife::BriefcaseReload do
  let(:file_path) { __FILE__ }

  it "re-encrypts data bag's items" do
    knife_config do
      briefcase_signers 'test+knife-briefcase-2@3ofcoins.net'
      briefcase_holders [ 'test+knife-briefcase-1@3ofcoins.net' ]
    end
    expect { knife('briefcase', 'put', 'an-item-id', file_path).zero? }

    with_gnupg_home('without-1') do
      deny { knife('briefcase', 'get', 'an-item-id').zero? }
    end

    knife_config do
      briefcase_holders [
        'test+knife-briefcase-2@3ofcoins.net',
        'test+knife-briefcase-1@3ofcoins.net' ]
    end

    expect { knife('briefcase', 'reload', 'an-item-id').zero? }

    with_gnupg_home('without-1') do
      expect { knife('briefcase', 'get', 'an-item-id').zero? }
      expect { knife_stdout == File.read(file_path) }
    end
  end
end
