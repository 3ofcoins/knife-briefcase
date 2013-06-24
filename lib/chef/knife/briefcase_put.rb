require 'knife-briefcase/knife'

class Chef::Knife::BriefcasePut < KnifeBriefcase::Knife
  banner "knife briefcase put NAME [FILE]"

  def run
    encrypted = crypto.encrypt( GPGME::Data.from_io(file ? File.open(file) : stdin),
      :recipients => recipients,
      :sign => !!signers,
      :signers => signers,
      :always_trust => true)

    begin
      rest.post_rest("data", { "name" => data_bag_name })
      ui.info("Created data_bag[#{data_bag_name}]")
    rescue Net::HTTPServerException => e
      raise unless e.to_s =~ /^409/
      ui.info("data_bag[#{data_bag_name}] already exists")
    end

    item = Chef::DataBagItem.from_hash(
      'id' => item_name, 'content' => encrypted.to_s )
    item.data_bag(data_bag_name)
    begin
      rest.post_rest("data/#{data_bag_name}", item)
    rescue Net::HTTPServerException => e
      raise unless e.to_s =~ /^409/
      rest.put_rest("data/#{data_bag_name}/#{item_name}", item)
    end
  end
end
