gusztavvargadr_windows_update '' do
  action :install
end

chocolatey_package 'chocolatey' do
  action :upgrade
end

reboot 'gusztavvargadr_packer_windows::apply' do
  delay_mins 1
  action :reboot_now
  only_if { reboot_pending? }
end
