require 'knife-briefcase/knife'

class Chef::Knife::BriefcaseList < Chef::Knife
  include KnifeBriefcase::Knife
  banner "knife briefcase list"

  def run
    output(format_list_for_display(Chef::DataBag.load(data_bag_name)))
  end
end
