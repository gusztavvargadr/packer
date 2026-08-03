gusztavvargadr_windows_update '' do
  action :install
end

chocolatey_package 'chocolatey' do
  action :upgrade
end

reboot 'gusztavvargadr_packer_windows::apply' do
  delay_mins 1
  action :reboot_now
  only_if { node.run_state['gusztavvargadr_windows_updates_installed'] || reboot_pending? }
end
