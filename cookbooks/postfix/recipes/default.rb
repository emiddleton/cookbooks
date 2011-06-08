# remove default virtual/mta-0
package "mail-mta/ssmtp" do
  action :remove
end

portage_package_use "mail-mta/postfix" do
  use node[:postfix][:use_flags].sort.uniq
end

package "mail-mta/postfix"

group "postfix" do
  gid 207
end

group "postdrop" do
  gid 208
end

user "postfix" do
  uid 207
  gid 207
  home "/var/spool/postfix"
end

group "mail" do
  gid 12
  members %w(postfix)
  append true
end

user "mail" do
  uid 8
  gid 12
  home "/var/spool/mail"
end

directory "/etc/mail" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/mail/aliases" do
  source "aliases.erb"
  owner "root"
  group "root"
  mode "0644"
end

directory "/etc/postfix" do
  owner "root"
  group "root"
  mode "0755"
end

ipv6_str = node[:ipv6_enabled] ? ", ipv6" : ""

postconf "base" do
  set :myhostname => node[:fqdn],
      :mydomain => node[:domain],
      :mynetworks_style => "host",
      :inet_protocols => "ipv4#{ipv6_str}"
end

postmaster "smtp" do
  stype "inet"
  priv "n"
  command "smtpd"
end

service "postfix" do
  action [:enable, :start]
end

execute "newaliases" do
  command "/usr/bin/newaliases"
  not_if do FileUtils.uptodate?("/etc/mail/aliases.db", %w(/etc/mail/aliases)) end
end

nrpe_command "check_postfix" do
  command "/usr/lib/nagios/plugins/check_pidfile /var/spool/postfix/pid/master.pid postfix/master"
end

nrpe_command "check_smtp" do
  command "/usr/lib/nagios/plugins/check_smtp -H localhost -t 3"
end

nagios_service "POSTFIX" do
  check_command "check_nrpe!check_postfix"
  servicegroups "postfix"
end

nagios_service "SMTP" do
  check_command "check_nrpe!check_smtp"
  servicegroups "postfix"
end

nagios_service_dependency "SMTP" do
  depends %w(POSTFIX)
end

munin_plugin "postfix_mailstats" do
  source "postfix_mailstats"
  config ["user root", "group wheel", "env.logfile mail.log"]
end

%w(mailqueue mailvolume).each do |p|
  munin_plugin "postfix_#{p}" do
    config ["user root", "group wheel", "env.logfile mail.log"]
  end
end
