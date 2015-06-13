require 'chef'
require 'chef/role'

def upload_site_roles(files)
  roles = {}
  files.each do |f|
    role = role_from_file(f)
    roles[role.name] = role # original name as hash key
    role.name(role.name)
  end

  upload_roles(roles.values)

  roles
end

def role_from_file(file)
  role = Chef::Role.new
  puts file
  role.from_file(file)
  role
end

def upload_roles(roles)
  roles.each do |role|
    role.save
    puts "Uploaded #{role.name.inspect} role."
  end
end


