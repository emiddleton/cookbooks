include_recipe "portage"

portage_package_keywords "app-vim/nginx-syntax"
portage_package_keywords "=www-servers/nginx-0.8.49"
portage_package_keywords ">=www-servers/nginx-0.8.34-r1" do
  action :delete
end

nginx_default_use_flags = %w(
  -nginx_modules_http_browser
  -nginx_modules_http_empty_gif
  -nginx_modules_http_geo
  -nginx_modules_http_memcached
  -nginx_modules_http_ssi
  -nginx_modules_http_userid
  aio
  nginx_modules_http_realip
  nginx_modules_http_stub_status
)

portage_package_use "www-servers/nginx" do
  use(nginx_default_use_flags + node[:nginx][:use_flags])
end

group "nginx" do
  gid 82
end

user "nginx" do
  uid 82
  gid 82
  home "/dev/null"
  shell "/sbin/nologin"
end

package "www-servers/nginx"

service "nginx" do
  supports :status => true
  action :enable
end

directory "/etc/nginx" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

directory "/etc/nginx/modules" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/nginx/modules/fastcgi.conf" do
  source "fastcgi.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

link "/etc/nginx/fastcgi.conf" do
  to "/etc/nginx/modules/fastcgi.conf"
end

file "/etc/nginx/fastcgi_params" do
  action :delete
end

directory "/etc/nginx/servers" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/nginx/servers/default.conf" do
  source "default.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

cookbook_file "/etc/nginx/servers/status.conf" do
  source "status.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end
