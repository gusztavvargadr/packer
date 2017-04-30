property :updates_options, Hash

default_action :install

action :install do
  return if updates_options.nil?
end
