gusztavvargadr_windows_defender '' do
  action :disable
end

gusztavvargadr_windows_uac '' do
  action :disable
end

gusztavvargadr_windows_remote_desktop '' do
  action :enable
end

gusztavvargadr_windows_updates '' do
  action :configure
end
