package_keywords "=app-admin/chef-0.10.0"
package_keywords "=app-admin/chef-expander-0.10.0"
package_keywords "=app-admin/chef-server-0.10.0"
package_keywords "=app-admin/chef-server-api-0.10.0"
package_keywords "=app-admin/chef-server-webui-0.10.0"
package_keywords "=app-admin/chef-solr-0.10.0"
package_keywords "=dev-libs/gecode-3.5.0"
package_keywords "=dev-ruby/abstract-1.0.0-r1"
package_keywords "=dev-ruby/addressable-2.2.6"
package_keywords "=dev-ruby/amqp-0.6.7"
package_keywords "=dev-ruby/bundler-1.0.14 **"
package_keywords "=dev-ruby/bunny-0.6.0-r1"
package_keywords "=dev-ruby/dep_selector-0.0.8"
package_keywords "=dev-ruby/em-http-request-0.2.14"
package_keywords "=dev-ruby/erubis-2.7.0"
package_keywords "=dev-ruby/eventmachine-0.12.10-r2"
package_keywords "=dev-ruby/extlib-0.9.15"
package_keywords "=dev-ruby/fast_xs-0.7.3"
package_keywords "=dev-ruby/fssm-0.2.5"
package_keywords "=dev-ruby/haml-3.1.1"
package_keywords "=dev-ruby/hpricot-0.8.4"
package_keywords "=dev-ruby/libxml-2.0.6"
package_keywords "=dev-ruby/merb-assets-1.1.3"
package_keywords "=dev-ruby/merb-core-1.1.3"
package_keywords "=dev-ruby/merb-haml-1.1.3"
package_keywords "=dev-ruby/merb-helpers-1.1.3"
package_keywords "=dev-ruby/merb-param-protection-1.1.3"
package_keywords "=dev-ruby/mime-types-1.16-r2"
package_keywords "=dev-ruby/mixlib-authentication-1.1.4"
package_keywords "=dev-ruby/mixlib-cli-1.2.0"
package_keywords "=dev-ruby/mixlib-config-1.1.2"
package_keywords "=dev-ruby/mixlib-log-1.3.0"
package_keywords "=dev-ruby/moneta-0.6.0-r1"
package_keywords "=dev-ruby/net-ssh-2.1.4"
package_keywords "=dev-ruby/net-ssh-multi-1.0.1-r1"
package_keywords "=dev-ruby/ohai-0.6.4"
package_keywords "=dev-ruby/polyglot-0.3.1"
package_keywords "=dev-ruby/rack-1.0.1-r2"
package_keywords "=dev-ruby/rest-client-1.6.1"
package_keywords "=dev-ruby/systemu-2.2.0"
package_keywords "=dev-ruby/treetop-1.4.9"
package_keywords "=dev-ruby/yajl-ruby-0.8.2"
package_keywords "=net-misc/rabbitmq-server-2.4.1"
package_keywords "=www-servers/thin-1.2.5-r1"

package "app-admin/chef"

directory "/var/lib/chef/cache" do
  group "root"
  mode "0750"
end

template "/etc/chef/client.rb" do
  source "client.rb.erb"
  owner "root"
  group "root"
  mode "0644"
end

service "chef-client" do
  action [:disable, :stop]
end

cookbook_file "/etc/logrotate.d/chef" do
  source "chef.logrotate"
  owner "root"
  group "root"
  mode "0644"
end

file "/var/log/chef/client.log" do
  owner "root"
  group "root"
  mode "0600"
end
