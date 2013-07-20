require 'knife-briefcase/knife'

class Chef::Knife::BriefcaseAnnexHook < KnifeBriefcase::Knife
  banner "knife briefcase annex hook"

  def run
    item_id = ENV['ANNEX_KEY'].gsub(/[^[:alnum:]_\-]+/, '_')

    case ENV['ANNEX_ACTION']
    when 'store'
      require 'chef/knife/briefcase_put'
      run_subcommand BriefcasePut, item_id, ENV['ANNEX_FILE']
    when 'retrieve'
      require 'chef/knife/briefcase_get'
      run_subcommand BriefcaseGet, item_id, ENV['ANNEX_FILE']
    when 'remove'
      delete_object(Chef::DataBagItem, item_id, 'briefcase_item') do
        rest.delete_rest("data/#{data_bag_name}/#{item_name}")
      end
    when 'checkpresent'
      begin
        data_bag = Chef::DataBag.load(data_bag_name)
        puts ENV['ANNEX_KEY'] if data_bag.include?(item_id)
      rescue Net::HTTPServerException => e
        # Ignore 404 - checkpresent should succeed and *not* print the
        # key when not found.
        raise unless Net::HTTPNotFound === e.data
      end
    else
      raise RuntimeError, "Unknown ANNEX_ACTION #{ENV['ANNEX_ACTION'].inspect}"
    end
  end

  def run_subcommand(cls, *args)
    subcmd = cls.new
    subcmd.ui = ui
    subcmd.name_args = args
    subcmd.config[:data_bag] = data_bag_name
    subcmd.run
  end

  def data_bag_name
    config[:data_bag] || Chef::Config[:briefcase_annex_data_bag] || 'annex'
  end
end
