default[:chef][:client][:node_name] = node[:fqdn]
default[:chef][:client][:server_url] = "https://chef.#{node[:domain]}"
