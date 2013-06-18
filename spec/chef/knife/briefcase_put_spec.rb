require 'spec_helper'

require 'chef/knife/briefcase_put'

describe Chef::Knife::BriefcasePut do
  before do
    knife_config do
      briefcase_signers 'test+knife-briefcase-1@3ofcoins.net'
      briefcase_holders [
        'test+knife-briefcase-2@3ofcoins.net',
        'test+knife-briefcase-1@3ofcoins.net' ]
    end
  end

  it 'stores encrypted file to a data bag' do
    expect { knife('briefcase', 'put', 'an-item-id', __FILE__).zero? }

    briefcase = ridley.data_bag.find('briefcase')
    expect { briefcase }

    item = briefcase.item.find('an-item-id')
    expect { item }
    expect { item['id'] == 'an-item-id' }
    expect { item['content'] =~ /^-----BEGIN PGP MESSAGE-----/ }

    executed_block = false
    expect { crypto.decrypt(GPGME::Data.from_str(item['content'])).to_s == File.read(__FILE__) }

    _verify_yields = false
    expect { crypto.verify(GPGME::Data.from_str(item['content'])) { |sig| _verify_yields = true ; sig.valid? } }
    expect { _verify_yields }
  end

  it 'reads from stdin when no file given' do
    @knife_stdin = 'whatever'
    expect { knife('briefcase', 'put', 'an-item-id').zero? }

    encrypted = ridley.data_bag.find('briefcase').item.find('an-item-id')['content']
    expect { crypto.decrypt(GPGME::Data.from_str(encrypted)).to_s == 'whatever' }
  end

  it 'reads from stdin for file named "-"' do
    @knife_stdin = 'whatever'
    expect { knife('briefcase', 'put', 'an-item-id', '-').zero? }

    encrypted = ridley.data_bag.find('briefcase').item.find('an-item-id')['content']
    expect { crypto.decrypt(GPGME::Data.from_str(encrypted)).to_s == 'whatever' }
  end

  it 'overwrites previously stored value' do
    spec_helper = Pathname.new(__FILE__).dirname.dirname.dirname.join('spec_helper.rb')

    expect { knife('briefcase', 'put', 'an-item-id', __FILE__).zero? }
    expect { knife('briefcase', 'put', 'an-item-id', spec_helper.to_s).zero? }

    encrypted = ridley.data_bag.find('briefcase').item.find('an-item-id')['content']
    deny { crypto.decrypt(GPGME::Data.from_str(encrypted)).to_s == File.read(__FILE__) }
    expect { crypto.decrypt(GPGME::Data.from_str(encrypted)).to_s == spec_helper.read }
  end
end
