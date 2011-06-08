untag("nagios-SSH")

package "net-misc/openssh"

nodes = node.run_state[:nodes].select do |n|
  n[:keys] and n[:keys][:ssh]
end

template "/etc/ssh/ssh_known_hosts" do
  source "known_hosts.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :nodes => nodes
end

node.set[:ssh][:server][:matches] = {}

%w(ssh sshd).each do |f|
  template "/etc/ssh/#{f}_config" do
    source "#{f}_config.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[sshd]"
  end
end

service "sshd" do
  action [:enable, :start]
end

execute "root-ssh-key" do
  command "ssh-keygen -f /root/.ssh/id_rsa -N ''"
  creates "/root/.ssh/id_rsa"
end

nagios_service "SSH" do
  check_command "check_ssh!22"
  servicegroups "system"
end
