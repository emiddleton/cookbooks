# to make things faster, add the node list to our run_state for later use
node.run_state[:nodes] = search(:node, "ipaddress:[* TO *]")

# load ohai plugins first
include_recipe "ohai"

begin
  include_recipe "base::#{node[:platform]}"
rescue
  raise "The base module has not been ported to your platform (#{node[:platform]})"
end

include_recipe "git"
include_recipe "vim"

execute "git init" do
  cwd "/etc"
  creates "/etc/.git"
end

directory "/etc/.git" do
  owner "root"
  group "root"
  mode "0700"
end

file "/etc/.gitignore" do
  content <<-EOS
*~
adjtime
config-archive
hosts.deny*
ld.so.cache
mtab
resolv*
EOS
  owner "root"
  group "root"
  mode "0644"
end

bash "commit changes to /etc" do
  code <<-EOS
cd /etc
git add -A .
git commit -m 'automatic commit during chef-client run'
git gc
EOS
  not_if { %x(env GIT_DIR=/etc/.git GIT_WORK_TREE=/etc git status --porcelain).strip.empty? }
end

template "/etc/hosts" do
  owner "root"
  group "root"
  mode "0644"
  source "hosts.erb"
  variables :nodes => node.run_state[:nodes]
end

file "/etc/resolv.conf" do
  owner "root"
  group "root"
  mode "0644"
  content "search #{node[:domain]}\nnameserver 8.8.8.8\nnameserver 8.8.4.4\n"
end

execute "sysctl-reload" do
  command "/sbin/sysctl -p /etc/sysctl.conf"
  action :nothing
end

template "/etc/sysctl.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "sysctl.conf.erb"
  notifies :run, "execute[sysctl-reload]"
end

execute "init-reload" do
  command "/sbin/telinit q"
  action :nothing
end

template "/etc/inittab" do
  owner "root"
  group "root"
  mode "0644"
  source "inittab.erb"
  notifies :run, "execute[init-reload]"
  backup 0
end

link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{node[:timezone]}"
end

execute "locale-gen" do
  command "/usr/sbin/locale-gen"
  action :nothing
end

template "/etc/locale.gen" do
  # TODO: make it configurable
  owner "root"
  group "root"
  mode "0644"
  source "locale.gen.erb"
  notifies :run, "execute[locale-gen]"
end

%w(/root /root/.ssh).each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "0700"
  end
end

link "/dev/fd" do
  to "/proc/self/fd"
end

link "/dev/stdin" do
  to "/dev/fd/0"
end

link "/dev/stdout" do
  to "/dev/fd/1"
end

link "/dev/stderr" do
  to "/dev/fd/2"
end

# enable munin plugins
base_plugins = %w(
  cpu
  df
  entropy
  forks
  load
  memory
  open_files
  open_inodes
  processes
  iostat
  swap
  vmstat
)

base_plugins.each do |p|
  munin_plugin p
end

# reset all attributes to make sure cruft is being deleted on chef-client run
node.default[:nagios][:services] = {}

nagios_service "PING" do
  check_command "check_ping!100.0,20%!500.0,60%"
  servicegroups "system"
end

nagios_service "ZOMBIES" do
  check_command "check_munin_single!processes!zombie!5!10"
  servicegroups "system"
end

nagios_service "PROCS" do
  check_command "check_munin!processes!300!1000"
  servicegroups "system"
end

nagios_plugin "raid" do
  source "check_raid"
end

nrpe_command "check_raid" do
  command "/usr/lib/nagios/plugins/check_raid"
end

nagios_service "RAID" do
  check_command "check_nrpe!check_raid"
  servicegroups "system"
end

nagios_service "LOAD" do
  check_command "check_munin!load!#{node[:cpu][:total]*3}!#{node[:cpu][:total]*10}"
  servicegroups "system"
end

nagios_service "DISKS" do
  check_command "check_munin!df!90!95"
  notification_interval 15
  servicegroups "system"
end

nagios_service_escalation "DISKS" do
  notification_interval 15
end

nagios_service "SWAP" do
  check_command "check_munin!swap!128!1024"
  notification_interval 180
  servicegroups "system"
end
