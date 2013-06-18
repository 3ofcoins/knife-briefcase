require 'spec_helper'

# A smoke test spec to make sure tests actually work

module KnifeBriefcase
  describe VERSION do
    it 'is equal to itself' do
      expect { VERSION == KnifeBriefcase::VERSION }
    end
  end
end
