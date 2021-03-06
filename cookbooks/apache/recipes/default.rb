make_conf "apache" do
  overrides [
    [ :APACHE2_MPMS, node[:apache][:mpm] ],
    [ :APACHE2_MODULES, %w(actions alias auth_basic authn_default authn_file
    authz_default authz_groupfile authz_host authz_user autoindex cgi cgid
    deflate dir env expires filter headers info log_config mime mime_magic
    proxy rewrite setenvif status) ].flatten
  ]
end

portage_package_use "dev-libs/apr-util" do
  use node[:apache][:apr_util][:use]
end

portage_package_use "www-servers/apache" do
  use %w(static)
end

package "www-servers/apache"

template "/etc/apache2/httpd.conf" do
  source "httpd.conf"
  mode "0644"
  owner "root"
  group "root"
end

%w(common_redirect log_rotate extract_forwarded).each do |pkg|
  package "www-apache/mod_#{pkg}"
end

%w(
  00_default_vhost.conf
  00_default_ssl_vhost.conf
  default_vhost.include
).each do |conf|
  file "/etc/apache2/vhosts.d/#{conf}" do
    action :delete
  end
end

# old cruft, filename is actually 20_mod_fastcgi_handler.conf
file "/etc/apache2/modules.d/10_mod_fastcgi_handler.conf" do
  action :delete
end

%w(
  00_default_settings
  00_error_documents
  00_languages
  00_mod_autoindex
  00_mod_info
  00_mod_log_config
  00_mod_mime
  00_mod_status
  00_mod_userdir
  00_mpm
  10_mod_log_rotate
  10_mod_mem_cache
  20_mod_common_redirect
  40_mod_ssl
  46_mod_ldap
  98_mod_extract_forwarded
).each do |m|
  apache_module m do
    template "#{m}.conf"
  end
end

apache_vhost "status" do
  template "status.conf"
end

apache_vhost "00-default" do
  template "default.conf"
end

template "/etc/conf.d/apache2" do
  source "apache2.confd"
  mode "0644"
  owner "root"
  group "root"
  notifies :restart, "service[apache2]"
end

service "apache2" do
  action [:start, :enable]
end

syslog_config "90-apache" do
  template "syslog.conf"
end

cookbook_file "/etc/logrotate.d/apache2" do
  source "logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end

# errors go to syslog, no need to confuse everybody with empty error_logs
file "/var/log/apache2/error_log" do
  action :delete
  backup 0
end

# nagios service checks
if tagged?("nagios-client")
  package "dev-perl/libwww-perl"

  nagios_plugin "apache2" do
    source "check_apache2"
  end

  nrpe_command "check_apache2" do
    command "/usr/lib/nagios/plugins/check_apache2 -H localhost -p 8031 -u / -w 20 -c 3"
  end

  nagios_service "APACHE2" do
    check_command "check_nrpe!check_apache2"
  end
end
