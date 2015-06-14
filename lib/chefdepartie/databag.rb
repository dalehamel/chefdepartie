require 'chef'

module Chefdepartie
  module Databags
    def self.upload_all
      puts "Uploading databags"
      cookbooks = File.dirname(Chef::Config[:cookbook_path])
      bags = Dir[File.join(cookbooks,'data_bags','/*')]
      upload_all_data_bags(bags)
    end

  private

    def self.upload_data_bag_items(items)
      current_bags = Chef::DataBag.list.keys.to_set

      items.each do |item|
        bag_name = item.data_bag
        unless current_bags.include?(bag_name)
          bag = Chef::DataBag.new
          bag.name(bag_name)
          bag.create
          puts "Created databag #{bag_name.inspect}."
          current_bags << bag_name
        end

        item.save
        puts "Uploaded databag #{bag_name.inspect}, item #{item.id.inspect}."
      end
    end

    # Takes a list of data bag names, and uploads all data bag items from within that bag.
    def self.upload_all_data_bags(data_bags)
      items = []
      secret = Chef::EncryptedDataBagItem.load_secret(Chef::Config[:encrypted_data_bag_secret])

      data_bags.each do |data_bag|
        bag_name = File.basename(data_bag)
        files = Dir.glob(File.join(data_bag,"*.json")).flatten

        files.each do |item_file|
          raw_data = Chef::JSONCompat.from_json(IO.read(item_file))

          item = Chef::DataBagItem.new
          item.data_bag bag_name
          if is_encrypted_data_bag?(raw_data)
            item.raw_data = Chef::EncryptedDataBagItem.new(raw_data, secret).to_hash
          else
            item.raw_data = raw_data
          end
          items << item
        end
      end

      upload_data_bag_items(items)
    end

    def self.is_encrypted_data_bag?(raw_data)
      # TODO: use Chef::EncryptedDataBagItem::CheckEncrypted when we move to Chef 12
      first_sub_item = Array(raw_data.find { |k, v| k != 'id' }).last
      !!(first_sub_item.kind_of?(Hash) && first_sub_item['encrypted_data'] && first_sub_item['cipher'])
    end
  end
end
