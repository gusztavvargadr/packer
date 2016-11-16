property :edition, String, name_property: true

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/packer_sql/2014_#{edition}"

  directory directory_path do
    recursive true
    action :create
  end

  configuration_file_name = 'configuration.ini'
  configuration_file_path = "#{directory_path}/#{configuration_file_name}"
  configuration_file_source = '2014.ini'
  cookbook_file configuration_file_path do
    source configuration_file_source
    cookbook 'packer_sql'
    action :create
  end

  installer_file_name = node['packer_sql']["2014_#{edition}"]['installer_file_name']
  installer_file_path = "#{directory_path}/#{installer_file_name}"
  installer_file_source = node['packer_sql']["2014_#{edition}"]['installer_file_url']
  remote_file installer_file_path do
    source installer_file_source
    action :create
  end

  extracted_directory_path = directory_path
  installer_file_extension = ::File.extname(installer_file_name)
  if installer_file_extension == '.iso'
    extracted_directory_path = 'I:/'
    packer_windows_iso installer_file_path do
      drive_letter 'I'
      action :mount
    end
  else
    extracted_directory_path = "#{directory_path}/extracted"
    packer_windows_powershell_script_elevated "Extract SQL Server 2014 #{edition}" do
      code <<-EOH
        Start-Process "#{installer_file_path.tr('/', '\\')}" "/q /x:#{extracted_directory_path.tr('/', '\\')}" -Wait
      EOH
      action :run
    end
  end

  extracted_installer_file_name = 'SETUP.EXE'
  extracted_installer_file_path = "#{extracted_directory_path}/#{extracted_installer_file_name}"
  packer_windows_powershell_script_elevated "Install SQL Server 2014 #{edition}" do
    code <<-EOH
      Start-Process "#{extracted_installer_file_path.tr('/', '\\')}" "/CONFIGURATIONFILE=#{configuration_file_path.tr('/', '\\')} /IACCEPTSQLSERVERLICENSETERMS" -Wait
    EOH
    action :run
  end

  if installer_file_extension == '.iso'
    packer_windows_iso installer_file_path do
      action :dismount
    end
  end

  powershell_script 'Enable Firewall' do
    code <<-EOH
     netsh advfirewall firewall add rule name="SQL Server" dir=in localport=1433 protocol=TCP action=allow
    EOH
    action :run
  end
end
