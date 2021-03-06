unless node[:skip][:nagios_client]
  tag("nagios-client")

  include_recipe "munin::node"

  package "net-analyzer/nagios-nrpe"
  package "net-analyzer/nagios-nsca"

  directory "/etc/nagios" do
    owner "nagios"
    group "nagios"
    mode "0750"
  end

  directory "/etc/nagios/nrpe.d" do
    owner "root"
    group "root"
    mode "0755"
  end

  service "nrpe" do
    action [:enable, :start]
  end

  master = node.run_state[:nodes].select do |n|
    n[:tags].include?("nagios-master")
  end.first

  %w(nrpe send_nsca).each do |f|
    nagios_conf f do
      subdir false
      mode "0640"
      variables :master => master
    end
  end

  # third-party plugins
  package "net-analyzer/nagios-check_pidfile"
end
