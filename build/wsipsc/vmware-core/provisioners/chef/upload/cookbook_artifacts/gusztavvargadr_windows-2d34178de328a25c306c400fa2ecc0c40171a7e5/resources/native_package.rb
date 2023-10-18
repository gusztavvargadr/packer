unified_mode true

provides :gusztavvargadr_windows_native_package

property :options, Hash, default: {}

default_action :install

action :install do
  options = new_resource.options

  source = options['source']
  install = options['install'].nil? ? {} : options['install']
  executable = options['executable']

  return if !executable.nil? && ::File.exist?(executable)

  download_directory_path = "#{Chef::Config['file_cache_path']}/gusztavvargadr_windows_native_package"
  download_file_path = "#{download_directory_path}/#{::File.basename(source)}"

  directory download_directory_path do
    recursive true
    action :create
  end

  remote_file download_file_path do
    action :create
    source source
  end

  script_name = "Install Native package '#{new_resource.name}'"
  script_code = "Start-Process \"#{download_file_path.tr('/', '\\')}\" \"#{install.join(' ')}\" -Wait"

  powershell_script script_name do
    code script_code
    action :run
  end
end
