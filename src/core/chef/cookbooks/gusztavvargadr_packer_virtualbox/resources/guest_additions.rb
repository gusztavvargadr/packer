property :guest_additions_version, String, name_property: true

default_action :install

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/gusztavvargadr_packer_virtualbox/guest_additions"

  directory directory_path do
    recursive true
    action :create
  end

  iso_file_name = "VBoxGuestAdditions_#{guest_additions_version}.iso"
  iso_file_path = "#{directory_path}/#{iso_file_name}"
  iso_file_source_url = "http://download.virtualbox.org/virtualbox/#{guest_additions_version}/#{iso_file_name}"

  remote_file iso_file_path do
    source iso_file_source_url
    action :create
  end

  gusztavvargadr_windows_iso iso_file_path do
    drive_letter 'I'
    action :mount
  end

  powershell_script 'Install VirtualBox Guest' do
    code <<-EOH
      Start-Process "I:/cert/VBoxCertUtil.exe" "add-trusted-publisher I:/cert/vbox-sha1.cer" -Wait
      Start-Process "I:/cert/VBoxCertUtil.exe" "add-trusted-publisher I:/cert/vbox-sha256.cer" -Wait
      Start-Process "I:/cert/VBoxCertUtil.exe" "add-trusted-publisher I:/cert/vbox-sha256-r3.cer" -Wait
      Start-Process "I:/VBoxWindowsAdditions.exe" "/S" -Wait
    EOH
    action :run
  end

  gusztavvargadr_windows_iso iso_file_path do
    action :dismount
  end
end
