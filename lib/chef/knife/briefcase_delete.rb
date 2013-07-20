require 'knife-briefcase/knife'

class Chef::Knife::BriefcaseDelete < KnifeBriefcase::Knife
  banner "knife briefcase delete NAME [NAME [...]]"

  def run
    @name_args.each do |item_name|
      delete_object(Chef::DataBagItem, item_name, 'briefcase_item') do
        rest.delete_rest("data/#{data_bag_name}/#{item_name}")
      end
    end
  end
end
