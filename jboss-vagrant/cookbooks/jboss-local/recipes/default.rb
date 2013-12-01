#
# Cookbook Name:: jboss
# Recipe:: default
#
# Copyright 2011, Bryan W. Berry
#
# license Apache v2.0
#

jboss_home = node['jboss']['jboss_home']
jboss_user = node['jboss']['jboss_user']

tarball_name = node['jboss']['dl_url'].
  split('/')[-1].
  sub!('.tar.gz', '')
path_arr = jboss_home.split('/')
path_arr.delete_at(-1)
jboss_parent = path_arr.join('/')

user jboss_user do
  comment "JBoss User"
  action :create
  home "/home/jboss"
  supports :manage_home => true
end

directory jboss_parent do
  group jboss_user
  owner jboss_user
  mode "0755"
  recursive true
  action :create
end

# get files
bash "put_files" do
  code <<-EOH
  set +x
  cd /tmp
  if [ ! -f #{tarball_name}.tar.gz ]; then
    wget -c #{node['jboss']['dl_url']}
  fi

  if [ ! -d #{jboss_home} ]; then  
    tar xvzf #{tarball_name}.tar.gz -C #{jboss_parent}
    chown -R jboss:jboss #{jboss_parent}
    mv #{jboss_parent}/#{tarball_name} #{jboss_home}
  fi
  EOH
end

%w{ domain standalone }.each do |path|
  file("#{jboss_home}/#{path}/configuration/mgmt-users.properties") { action :delete }

  file "#{jboss_home}/#{path}/configuration/mgmt-users.properties" do
    content "# DO NOT EDIT - AUTOMAGICALLY GENERATED
" + node['jboss']['jboss_admins']
    owner jboss_user
    group jboss_user
    mode  "0640"
    action :create
  end
end

# template init file
template "/etc/init/jboss.conf" do
  source "init_ubuntu.erb"
  mode "0755"
  owner "root"
  group "root"
end

template "#{jboss_home}/bin/standalone.conf" do
  source "standalone.erb"
  mode "0755"
  owner jboss_user
  group jboss_user
end

# template jboss-log4j.xml

# start service
service "jboss" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
