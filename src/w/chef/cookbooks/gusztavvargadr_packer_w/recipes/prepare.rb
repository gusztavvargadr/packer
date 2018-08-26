gusztavvargadr_windows_updates '' do
  action [:enable, :start, :configure]
end

if ENV['PACKER_BUILDER'].include?('virtualbox')
  gusztavvargadr_packer_w_virtualbox_guest_additions '' do
    guest_additions_options node['gusztavvargadr_packer_w']['virtualbox_guest_additions']
    action :install
  end
end
