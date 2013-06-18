require 'spec_helper'

require 'tempfile'

require 'chef/knife/briefcase_get'

describe Chef::Knife::BriefcaseGet do
  let(:file_path) { __FILE__ }

  before do
    knife_config do
      briefcase_signers 'test+knife-briefcase-1@3ofcoins.net'
      briefcase_holders [
        'test+knife-briefcase-2@3ofcoins.net',
        'test+knife-briefcase-1@3ofcoins.net' ]
    end
    expect { knife('briefcase', 'put', 'an-item-id', file_path).zero? }
  end

  it 'retrieves the stored encrypted file from the data bag' do
    expect { knife('briefcase', 'get', 'an-item-id').zero? }
    expect { knife_stdout == File.read(file_path) }
  end

  it 'writes to a provided file' do
    Tempfile.open('output') do |outf|
      expect { knife('briefcase', 'get', 'an-item-id', outf.path).zero? }
      expect { outf.read == File.read(file_path) }
    end
  end

  it 'writes to stdout for file named "-"' do
    expect { knife('briefcase', 'get', 'an-item-id', '-').zero? }
    expect { knife_stdout == File.read(file_path) }
  end

  it 'fails when it cannot verify signature' do
    with_gnupg_home('without-1') do
      deny { knife('briefcase', 'get', 'an-item-id').zero? }
      expect { knife_stderr =~ /Cannot verify signature/ }
    end
  end
end
