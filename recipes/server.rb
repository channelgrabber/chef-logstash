# Encoding: utf-8
#
# Author:: John E. Vincent
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2012, John E. Vincent
# Copyright 2012, Bryan W. Berry
# License: Apache 2.0
# Cookbook Name:: logstash
# Recipe:: server
#
#

# install logstash 'server'

name = 'server'

logstash_instance name do
  action            :create
end

logstash_service name do
  action      [:enable]
end

logstash_config name do
  templates({
    'logstash.conf' => 'server.conf.erb'
  })
  variables({
    'patterns_dir' => Logstash.get_attribute_or_default(node, name, 'patterns_dir'),
    'enable_embedded_es' => Logstash.get_attribute_or_default(node, name, 'enable_embedded_es'),
    'es_server_ip' => Logstash.get_attribute_or_default(node, name, 'elasticsearch_ip'),
    'es_cluster' => Logstash.get_attribute_or_default(node, name, 'elasticsearch_cluster'),
    'graphite_server_ip' => Logstash.get_attribute_or_default(node, name, 'graphite_ip')
  })
  action [:create]
  notifies :restart, "logstash_service[#{name}]"
end

if Logstash.get_attribute_or_default(node, name, 'version') < "1.5.0"
  logstash_plugins 'contrib' do
    instance name
    action [:create]
  end
elsif node['logstash']['instance'].has_key?(name) && node['logstash']['instance'][name]['plugins']
  node['logstash']['instance'][name]['plugins'].each do |plugin|
    logstash_plugin plugin do
      instance name
      action [:install, :update]
    end
  end
end

logstash_pattern name do
  action [:create]
end
