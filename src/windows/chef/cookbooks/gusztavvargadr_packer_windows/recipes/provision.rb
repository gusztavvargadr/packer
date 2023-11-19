gusztavvargadr_windows_update '' do
  action :install
end

reboot 'gusztavvargadr_packer_windows::provision' do
  action :reboot_now
  only_if { reboot_pending? }
end
