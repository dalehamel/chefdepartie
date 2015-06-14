require 'chef'
require 'chef/role'

module Chefdepartie
  module Roles

    def self.upload_all
      puts "Uploading roles"
      cookbooks = File.dirname(Chef::Config[:cookbook_path])
      roles = []
      Find.find(File.join(cookbooks,'roles')){ |f| roles << f if f =~ /\.rb$/}
      upload_site_roles(roles)
    end

  private

    def self.upload_site_roles(files)
      roles = {}
      files.each do |f|
        role = role_from_file(f)
        roles[role.name] = role # original name as hash key
        role.name(role.name)
      end

      upload_roles(roles.values)

      roles
    end

    def self.role_from_file(file)
      role = Chef::Role.new
      puts file
      role.from_file(file)
      role
    end

    def self.upload_roles(roles)
      roles.each do |role|
        role.save
        puts "Uploaded #{role.name.inspect} role."
      end
    end
  end
end
