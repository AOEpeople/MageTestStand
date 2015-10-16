#
# Cookbook Name:: mageteststand
# Recipe:: default
#

include_recipe 'chef-sugar'
include_recipe 'dotdeb' if debian?
include_recipe 'redisio'
include_recipe 'redisio::enable'
include_recipe 'php'
include_recipe 'php::predis'
include_recipe 'php::xdebug'
include_recipe 'phpunit'
include_recipe 'magerun'
include_recipe 'modman'

ssh_known_hosts_entry 'github.com'

mysql2_chef_gem 'mageteststand' do
  action :install
end

mysql_service 'mageteststand' do
  version node['mysql']['version']
  bind_address node['mysql']['bind_address']
  port node['mysql']['port']
  initial_root_password node['mysql']['server_root_password']
  action [:create, :start]
end

mysql_client 'mageteststand' do
  action :create
end
