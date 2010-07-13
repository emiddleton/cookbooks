define :nagios_conf, :variables => {}, :subdir => true, :action => :create do
  subdir = if params[:subdir]
             "objects/"
           else
             ""
           end

  service = if params[:name] == "nrpe"
              "nrpe"
            else
              "nagios"
            end

  template "/etc/nagios/#{subdir}#{params[:name]}.cfg" do
    source "#{params[:name]}.cfg.erb"
    owner "nagios"
    group "nagios"
    mode "0664"
    variables params[:variables]
    notifies :restart, resources(:service => service), :delayed
    backup 0
    action params[:action]
  end
end
