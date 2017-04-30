property :tools_options, Hash

default_action :install

action :install do
  return if tools_options.nil?

  gusztavvargadr_packer_core_tools_chocolatey '' do
    tools_chocolatey_options tools_options['chocolatey']
    action :install
  end

  gusztavvargadr_packer_core_tools_windows '' do
    tools_windows_options tools_options['windows']
    action :install
  end

  gusztavvargadr_packer_core_tools_files '' do
    tools_files_options tools_options['files']
    action :create
  end
end
