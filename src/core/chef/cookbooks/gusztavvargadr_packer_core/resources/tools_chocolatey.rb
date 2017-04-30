property :tools_chocolatey_options, Hash

default_action :install

action :install do
  return if tools_chocolatey_options.nil?

  tools_chocolatey_options.each do |package_name, package_options|
    package_version = package_options.nil? ? nil : package_options['version']
    package_install = "--ignorechecksums #{package_options.nil? ? nil : package_options['install']}"
    if !package_options.nil? && package_options['ignorecodes']
      package_install = "#{package_install} --ignorepackagecodes"
    end

    if package_version.nil?
      chocolatey_package package_name do
        options package_install
        action :install
      end
    else
      chocolatey_package package_name do
        version package_version
        options package_install
        action :install
      end
    end
  end
end
