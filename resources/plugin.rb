actions :install, :remove

default_action :install if defined?(default_action)

attribute :name, kind_of: String, name_attribute: true
attribute :instance, kind_of: String
attribute :version, kind_of: String
attribute :user, kind_of: String
attribute :group, kind_of: String
attribute :base_directory, kind_of: String
