def load_current_resource
  @name = new_resource.name
  @instance = new_resource.instance || 'default'
  @base_directory = new_resource.base_directory || Logstash.get_attribute_or_default(node, @instance, 'basedir')
  @version = new_resource.version
  @user = new_resource.user || Logstash.get_attribute_or_default(node, @instance, 'user')
  @group = new_resource.group || Logstash.get_attribute_or_default(node, @instance, 'group')
  @instance_dir = "#{@base_directory}/#{@instance}"
end

action :install do
  install_cmd = "bin/plugin install"
  install_cmd << " --version #{@version}" if @version
  install_cmd << " '#{@name}'"

  uninstalled = false
  begin
    ex = execute "bin/plugin install #{@name}" do
      command install_cmd
      user    @user
      group   @group
      cwd     @instance_dir
      notifies    :restart, "logstash_service[#{ls_instance}]"
      not_if "bin/plugin install --installed '^#{@name}$'", :user => @user, :group => @group, :cwd => @instance_dir
    end
  rescue Mixlib::Shellout::ShelloutCommandFailed => e
    if uninstalled
      raise e
    end

    uninstalled = true

    remove_cmd = "bin/plugin uninstall '#{@name}'"

    ex = execute "bin/plugin uninstall #{@name}" do
      command remove_cmd
      user    @user
      group   @group
      cwd     @instance_dir
      notifies    :restart, "logstash_service[#{ls_instance}]"
      only_if "bin/plugin install --installed '^#{@name}$'", :user => @user, :group => @group, :cwd => @instance_dir
    end

    new_resource.updated_by_last_action(ex.updated_by_last_action?)

    retry
  end

  new_resource.updated_by_last_action(ex.updated_by_last_action?)
end

action :remove do
  remove_cmd = "bin/plugin uninstall '#{@name}'"

  ex = execute "bin/plugin uninstall #{@name}" do
    command remove_cmd
    user    @user
    group   @group
    cwd     @instance_dir
    notifies    :restart, "logstash_service[#{ls_instance}]"
    only_if "bin/plugin install --installed '^#{@name}$'", :user => @user, :group => @group, :cwd => @instance_dir
  end

  new_resource.updated_by_last_action(ex.updated_by_last_action?)
end
