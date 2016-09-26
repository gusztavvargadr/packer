property :version, String, default: node['packer_windows']['virtualbox_guest']['version']

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/packer_windows/virtualbox_guest"

  directory directory_path do
    recursive true
    action :create
  end

  iso_file_name = "VBoxGuestAdditions_#{version}.iso"
  iso_file_path = "#{directory_path}/#{iso_file_name}"
  iso_file_source_url = "http://download.virtualbox.org/virtualbox/#{version}/#{iso_file_name}"

  remote_file iso_file_path do
    source iso_file_source_url
    action :create
  end

  packer_windows_iso iso_file_path do
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

  packer_windows_iso iso_file_path do
    action :dismount
  end

  directory directory_path do
    action :delete
  end
end
