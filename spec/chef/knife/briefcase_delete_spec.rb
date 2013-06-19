require 'spec_helper'

require 'tempfile'

require 'chef/knife/briefcase_delete'

describe Chef::Knife::BriefcaseDelete do
  before do
    knife_config do
      briefcase_signers 'test+knife-briefcase-1@3ofcoins.net'
      briefcase_holders [
        'test+knife-briefcase-2@3ofcoins.net',
        'test+knife-briefcase-1@3ofcoins.net' ]
    end
    # knife_input = "y\n"
  end

  it 'deletes a previously uploaded item' do
    expect { knife('briefcase', 'put', 'an-item-id', __FILE__).zero? }
    expect { ridley.data_bag.find('briefcase').item.find('an-item-id') }
    expect { knife('briefcase', 'delete', '--yes', 'an-item-id').zero? }
    deny { ridley.data_bag.find('briefcase').item.find('an-item-id') }
  end

  it 'fails when item does not exist' do
    expect { rescuing { knife('briefcase', 'delete', '--yes', 'an-item-id') } }
  end

  it 'deletes multiple items' do
    items = %w[item-1 item-2 item-3]
    items.each do |item|
      expect { knife('briefcase', 'put', item, __FILE__).zero? }
    end

    items.each do |item|
      expect { ridley.data_bag.find('briefcase').item.find(item) }
    end

    expect { knife('briefcase', 'delete', '--yes', *items).zero? }

    items.each do |item|
      deny { ridley.data_bag.find('briefcase').item.find(item) }
    end
  end
end
