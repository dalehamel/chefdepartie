require 'chef'

# We monkeypatch chefzero because it does something really stupid with databags, not sure why.
# It prevents them from being mashes client side. This allows databags to by serialized
# So that chef-client will load it as a mash instead of a hash
# The change here is we comment out:
#
# data_bag_item = data_bag_item['raw_data']

module ChefZero
  module ChefData
    class DataNormalizer
      def self.normalize_data_bag_item(data_bag_item, data_bag_name, id, method)
        if method == 'DELETE'
          # TODO SERIOUSLY, WHO DOES THIS MANY EXCEPTIONS IN THEIR INTERFACE
          unless data_bag_item['json_class'] == 'Chef::DataBagItem' && data_bag_item['raw_data']
            data_bag_item['id'] ||= id
            data_bag_item = { 'raw_data' => data_bag_item }
            data_bag_item['chef_type'] ||= 'data_bag_item'
            data_bag_item['json_class'] ||= 'Chef::DataBagItem'
            data_bag_item['data_bag'] ||= data_bag_name
            data_bag_item['name'] ||= "data_bag_item_#{data_bag_name}_#{id}"
          end
        else
          # If it's not already wrapped with raw_data, wrap it.
          if data_bag_item['json_class'] == 'Chef::DataBagItem' && data_bag_item['raw_data']
            # data_bag_item = data_bag_item['raw_data']
          end
          # Argh.  We don't do this on GET, but we do on PUT and POST????
          if %w(PUT POST).include?(method)
            data_bag_item['chef_type'] ||= 'data_bag_item'
            data_bag_item['data_bag'] ||= data_bag_name
          end
          data_bag_item['id'] ||= id
        end
        data_bag_item
      end
    end
  end
end

module Chefdepartie
  module Databags
    def self.upload_all
      puts 'Uploading databags'
      cookbooks = File.dirname(Chef::Config[:cookbook_path])
      bags = Dir[File.join(cookbooks, 'data_bags', '/*')]
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
        files = Dir.glob(File.join(data_bag, '*.json')).flatten

        files.each do |item_file|
          next if Cache.cache(item_file)
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
      first_sub_item = Array(raw_data.find { |k, _v| k != 'id' }).last
      !!(first_sub_item.is_a?(Hash) && first_sub_item['encrypted_data'] && first_sub_item['cipher'])
    end
  end
end
