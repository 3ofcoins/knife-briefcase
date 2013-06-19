require 'knife-briefcase/knife'

class Chef::Knife::BriefcaseGet < KnifeBriefcase::Knife
  banner = "knife briefcase get NAME [FILE]"

  def run
    encrypted = Chef::DataBagItem.load(data_bag_name, @name_args[0]).raw_data['content']

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

    if file
      crypto.decrypt(GPGME::Data.from_str(encrypted), :output => File.open(file, 'w+'))
    else
      stdout.write(crypto.decrypt(GPGME::Data.from_str(encrypted)))
    end
  rescue GPGME::Error::DecryptFailed
    Chef::Log.fatal("Decryption failed")
    exit 1
  end
end
