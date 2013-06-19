require 'spec_helper'

require 'chef/knife/briefcase_list'

describe Chef::Knife::BriefcaseList do
  it "shows names of briefcase data bag's items" do
    knife_config do
      briefcase_signers 'test+knife-briefcase-1@3ofcoins.net'
      briefcase_holders [
        'test+knife-briefcase-2@3ofcoins.net',
        'test+knife-briefcase-1@3ofcoins.net' ]
    end
    expect { knife('briefcase', 'put', 'an-item-id', __FILE__).zero? }
    expect { knife('briefcase', 'list').zero? }
    expect { knife_stdout =~ /an-item-id/ }
  end
end
