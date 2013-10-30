require 'knife-briefcase/knife'

class Chef::Knife::BriefcaseReload < KnifeBriefcase::Knife
  banner "knife briefcase reload [NAME [NAME [...]]]"

  def run
    item_names = if @name_args.empty?
                   Chef::DataBag.load(data_bag_name).keys
                 else
                   @name_args
                 end

    item_names.each do |item_name|
      encrypted = Chef::DataBagItem.load(data_bag_name, item_name).raw_data['content']

      begin
        crypto.verify(GPGME::Data.from_str(encrypted)) do |sig|
          if sig.valid?
            Chef::Log.info(sig.to_s)
          else
            Chef::Log.error(sig.to_s)
            exit 1                  # TODO: --force
          end
        end
      rescue
        Chef::Log.error("Cannot verify signature: #{$!}")
        exit 1
      end

      recrypted = crypto.encrypt(
        crypto.decrypt(GPGME::Data.from_str(encrypted)),

      :recipients => recipients,
      :sign => !!signers,
      :signers => signers,
      :always_trust => true)

      item = Chef::DataBagItem.from_hash(
        'id' => item_name, 'content' => recrypted.to_s )
      item.data_bag(data_bag_name)
      rest.put_rest("data/#{data_bag_name}/#{item_name}", item)
    end
  end
end
