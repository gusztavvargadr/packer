native_packages = node['gusztavvargadr_windows']['native_packages']
native_packages.each do |native_package_name, native_package_options|
  gusztavvargadr_windows_native_package native_package_name do
    options native_package_options
    action :install
  end
end
