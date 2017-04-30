property :cleanup_options, Hash

default_action :run

action :run do
  return if cleanup_options.nil?

  gusztavvargadr_packer_core_cleanup '' do
    cleanup_options new_resource.cleanup_options
    action :run
  end
end
