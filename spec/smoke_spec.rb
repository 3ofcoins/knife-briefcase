require 'spec_helper'

require 'chef/knife/status'

describe Chef::Knife::Status do
  it 'can connect to chef-zero server' do
    expect { knife('status').zero? }
  end
end
