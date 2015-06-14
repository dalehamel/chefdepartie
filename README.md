# A quick little helper

In a kitchen, a chef de partie is a line cook who helps prepare the ingredients the real chef will use.

Chefdepartie is a wrapper around a chef-zero server, allowing you to easily upload all of your:

* Cookbooks (site)
* Librarian cookbooks
* Roles
* Data bags

This allows you to test out all of your cookbooks together without putting them on your actual chef server.

## Chefdepartie vs chef-solo

Since chef-zero provides the same interface as **a real chef server**, you can actually use knife with it!

This gives you a full chef sandbox, and can be useful for things like CI or packer image provisioning.

* View and edit data bags, without an internet connection
* Bootstrap test nodes (vagrant images, cloud servers, etc)

# Configuration

create a normal chef config file, but you only need to specify the following values:

```
chef_server_url  'http://localhost:4000'
client_key 'path_to_any_pemfile'
encrypted_data_bag_secret 'path_to_your_real_databag_secret'
cookbook_path 'path_to_your_cookbooks'
node_name 'any_name'
```

Then, provide this file to chefdepartie as an environment variable (yeah, this needs some tweaking)


# Invocation

Currently a little rough around the edges. You specify the chef config file to use, and then just run chefdepartie.

```
CHEFDEPARTIE_CONFIG=~/workspace/shopify/chefdepartie/config.rb  be ruby lib/chefdepartie.rb
```

# To do:

* Wrap launching server with something like thor
* Tests to ensure all uploads are working as expected
* CI for tests
