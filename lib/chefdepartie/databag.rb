require 'chef'
# Takes a list of data bag names, and uploads all data bag items from within that bag.
def upload_modified_data_bags(data_bags)
  items = []
  secret = Chef::EncryptedDataBagItem.load_secret(Chef::Config[:encrypted_data_bag_secret])

  bags = data_bags.map do |decorated_bag_name|
    bag_name = bare_bag_name = decorated_bag_name.split('/').last
    files = data_bag_paths.map {|folder| Dir.glob("#{folder}/#{bare_bag_name}/*.json")}.flatten
    bag_name = "#{@branch}__#{bare_bag_name}" unless master?

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

    bare_bag_name
  end

  upload_data_bag_items(items)
  bags.uniq
end

def data_bag_paths
  if ENV['COOKER_DATA_BAGS']
    ENV['COOKER_DATA_BAGS'].split(/:/).reject { |path| path.match(%r{/}) || path.match(/^\./) }
  else
    ['data_bags']
  end
end

def is_encrypted_data_bag?(raw_data)
  # TODO: use Chef::EncryptedDataBagItem::CheckEncrypted when we move to Chef 12
  first_sub_item = Array(raw_data.find { |k, v| k != 'id' }).last
  !!(first_sub_item.kind_of?(Hash) && first_sub_item['encrypted_data'] && first_sub_item['cipher'])
end
