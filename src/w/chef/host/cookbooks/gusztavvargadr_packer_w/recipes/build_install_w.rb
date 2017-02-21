packer_windows_uac '' do
  action :disable
end

packer_windows_remote_desktop '' do
  action :enable
end

if node['gusztavvargadr_packer_w']['provider'] == 'virtualbox'
  packer_windows_virtualbox_guest '' do
    action :install
  end
end

packer_windows_windows_updates '' do
  action [:enable, :start, :configure, :stop, :disable]
end
