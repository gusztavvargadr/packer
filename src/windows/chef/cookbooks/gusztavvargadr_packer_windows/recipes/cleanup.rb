gusztavvargadr_windows_updates '' do
  action :cleanup
  not_if { reboot_pending? }
end

reboot 'cleanup' do
  action :reboot_now
  only_if { reboot_pending? }
end
