property :cleanup_options, Hash

default_action :run

action :run do
  return if cleanup_options.nil?
end
