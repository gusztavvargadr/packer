gusztavvargadr_windows_updates '' do
  action :install
  not_if { reboot_pending? }
end
