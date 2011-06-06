include_recipe "portage"
include_recipe "portage::porticron"

portage_package_keywords "=app-admin/lib_users-0.3"

%w(
  app-admin/pwgen
  app-arch/atool
  app-arch/xz-utils
  app-misc/tmux
  net-misc/rsync
  net-misc/wget
  sys-apps/iproute2
  sys-process/lsof
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

%w(
  /etc/init.d/net.lo
  /etc/init.d/net.eth0
  /etc/init.d/net.eth1
  /etc/runlevels/boot/net.lo
  /etc/runlevels/boot/net.eth0
  /etc/runlevels/boot/net.eth1
  /etc/runlevels/default/net.lo
  /etc/runlevels/default/net.eth0
  /etc/runlevels/default/net.eth1
  /etc/conf.d/net
).each do |f|
  file f do
    action :delete
    backup 0
  end
end

%w(devfs dmesg udev).each do |f|
  link "/etc/runlevels/sysinit/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(
  bootmisc
  consolefont
  fsck
  hostname
  hwclock
  keymaps
  localmount
  modules
  mtab
  network
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

%w(local netmount).each do |f|
  link "/etc/runlevels/default/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(killprocs mount-ro savecache).each do |f|
  link "/etc/runlevels/shutdown/#{f}" do
    to "/etc/init.d/#{f}"
  end
end
