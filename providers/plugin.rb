def load_current_resource
  @name = new_resource.name
  @instance = new_resource.instance || 'default'
  @base_directory = new_resource.base_directory || Logstash.get_attribute_or_default(node, @instance, 'basedir')
  @user = new_resource.user || Logstash.get_attribute_or_default(node, @instance, 'user')
  @group = new_resource.group || Logstash.get_attribute_or_default(node, @instance, 'group')
  @instance_dir = "#{@base_directory}/#{@instance}"
end

action :install do
  ex = execute "bin/plugin install #{@name}" do
    user     @user
    group    @group
    cwd      @instance_dir
    notifies :restart, "logstash_service[#{@instance}]", :delayed
    not_if   "bin/plugin install --installed '^#{@name}$'", :user => @user, :group => @group, :cwd => @instance_dir
  end
  new_resource.updated_by_last_action(ex.updated_by_last_action?)
end

action :install do
  ex = execute "bin/plugin update #{@name}" do
    user     @user
    group    @group
    cwd      @instance_dir
    notifies :restart, "logstash_service[#{@instance}]", :delayed
    only_if   "bin/plugin install --installed '^#{@name}$'", :user => @user, :group => @group, :cwd => @instance_dir
  end
  new_resource.updated_by_last_action(ex.updated_by_last_action?)
end

action :remove do
  ex = execute "bin/plugin uninstall #{@name}" do
    user     @user
    group    @group
    cwd      @instance_dir
    notifies :restart, "logstash_service[#{@instance}]", :delayed
    only_if  "bin/plugin install --installed '^#{@name}$'", :user => @user, :group => @group, :cwd => @instance_dir
  end
  new_resource.updated_by_last_action(ex.updated_by_last_action?)
end
