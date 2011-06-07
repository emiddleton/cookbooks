include_recipe "portage"
include_recipe "portage::porticron"

%w(
  app-admin/pwgen
  app-arch/atool
  app-arch/xz-utils
  app-misc/tmux
  net-misc/rsync
  net-misc/wget
  sys-apps/iproute2
).each do |pkg|
  package pkg
end

file "/etc/profile.d/prompt.sh" do
  action :delete
  backup 0
end

%w(shutdown reboot).each do |t|
  cookbook_file "/etc/init.d/#{t}.sh" do
    source "#{t}.sh"
    mode "0755"
    backup 0
  end
end

%w(hostname hwclock).each do |f|
  template "/etc/conf.d/#{f}" do
    source "#{f}.confd"
    mode "0644"
    backup 0
  end
end

file "/etc/conf.d/local" do
  action :delete
end

link "/etc/init.d/net.eth0" do
  to "/etc/init.d/net.lo"
end

%w(devfs dmesg udev).each do |f|
  link "/etc/runlevels/sysinit/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(
  bootmisc
  fsck
  hostname
  hwclock
  keymaps
  localmount
  modules
  mtab
  net.lo
  procfs
  root
  swap
  sysctl
  termencoding
  urandom
).each do |f|
  link "/etc/runlevels/boot/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(local net.eth0 netmount sshd udev-postmount).each do |f|
  link "/etc/runlevels/default/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(killprocs mount-ro savecache).each do |f|
  link "/etc/runlevels/shutdown/#{f}" do
    to "/etc/init.d/#{f}"
  end
end
