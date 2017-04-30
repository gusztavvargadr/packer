property :tools_windows_options, Hash

default_action :install

action :install do
  return if tools_windows_options.nil?

  tools_windows_options.each do |package_name, package_options|
    package_source = package_options.nil? ? nil : package_options['source']
    package_install = package_options.nil? ? nil : package_options['install']
    package_directory = package_options.nil? ? nil : package_options['directory']

    windows_package package_name do
      source package_source
      installer_type :custom
      options package_install
      action :install
      not_if { !package_directory.nil? && ::Dir.exist?(package_directory) }
    end
  end
end
