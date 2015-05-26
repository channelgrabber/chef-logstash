def load_current_resource
  @name = new_resource.name
  @instance = new_resource.instance || 'default'
  @base_directory = new_resource.base_directory || Logstash.get_attribute_or_default(node, @instance, 'basedir')
  @user = new_resource.user || Logstash.get_attribute_or_default(node, @instance, 'user')
  @group = new_resource.group || Logstash.get_attribute_or_default(node, @instance, 'group')
  @instance_dir = "#{@base_directory}/#{@instance}"
end

action :install do
  ls_name = @name
  ls_instance = @instance
  ls_basedir = @base_directory
  ls_user = @user
  ls_group = @group
  ls_instance_dir = @instance_dir

  ex = execute "bin/plugin install #{ls_name}" do
    user     ls_user
    group    ls_group
    cwd      ls_instance_dir
    notifies :restart, "logstash_service[#{ls_instance}]", :delayed
    not_if   "bin/plugin list --installed '^#{ls_name}$'", :user => ls_user, :group => ls_group, :cwd => ls_instance_dir
  end

  new_resource.updated_by_last_action(ex.updated_by_last_action?)
end

action :update do
  ls_name = @name
  ls_instance = @instance
  ls_basedir = @base_directory
  ls_user = @user
  ls_group = @group
  ls_instance_dir = @instance_dir

  ex = execute "bin/plugin update #{ls_name}" do
    user     ls_user
    group    ls_group
    cwd      ls_instance_dir
    notifies :restart, "logstash_service[#{ls_instance}]", :delayed
    only_if  "bin/plugin list --installed '^#{ls_name}$'", :user => ls_user, :group => ls_group, :cwd => ls_instance_dir
  end

  new_resource.updated_by_last_action(ex.updated_by_last_action?)
end

action :remove do
  ls_name = @name
  ls_instance = @instance
  ls_basedir = @base_directory
  ls_user = @user
  ls_group = @group
  ls_instance_dir = @instance_dir

  ex = execute "bin/plugin uninstall #{ls_name}" do
    user     ls_user
    group    ls_group
    cwd      ls_instance_dir
    notifies :restart, "logstash_service[#{ls_instance}]", :delayed
    only_if  "bin/plugin list --installed '^#{ls_name}$'", :user => ls_user, :group => ls_group, :cwd => ls_instance_dir
  end

  new_resource.updated_by_last_action(ex.updated_by_last_action?)
end
