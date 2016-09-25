property :version, String, default: node['packer_windows']['virtualbox_guest']['version']

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/packer_windows/virtualbox_guest"

  directory directory_path do
    recursive true
    action :create
  end

  file_name = "VBoxGuestAdditions_#{version}.iso"
  file_path = "#{directory_path}/#{file_name}"
  source_url = "#{node['packer_windows']['virtualbox_guest']['source_base_url']}/#{version}/#{file_name}"

  remote_file file_path do
    source source_url
    action :create
  end

  packer_windows_iso file_path do
    drive_letter 'I'
    action :mount
  end

  powershell_script 'Install VirtualBox Guest' do
    code <<-EOH
      Start-Process "I:/cert/VBoxCertUtil.exe" "add-trusted-publisher I:/cert/oracle-vbox.cer" -Wait
      Start-Process "I:/VBoxWindowsAdditions.exe" "/S" -Wait
    EOH
    action :run
  end

  packer_windows_iso file_path do
    action :dismount
  end

  directory directory_path do
    action :delete
  end
end
