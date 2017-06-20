gusztavvargadr_windows_pagefile '' do
  action :disable
end

gusztavvargadr_windows_updates '' do
  action [:enable, :start, :configure]
end

gusztavvargadr_windows_uac '' do
  action :disable
end

gusztavvargadr_windows_remote_desktop '' do
  action :enable
end
