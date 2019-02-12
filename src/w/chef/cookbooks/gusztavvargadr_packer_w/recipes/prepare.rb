# TODO: to boot and sysprep

gusztavvargadr_windows_pagefile '' do
  action :disable
end

gusztavvargadr_windows_updates '' do
  action [:enable, :start, :configure]
end

if ENV['PACKER_BUILDER'].to_s.include?('virtualbox')
  gusztavvargadr_packer_w_virtualbox_guest_additions '' do
    guest_additions_options node['gusztavvargadr_packer_w']['virtualbox_guest_additions']
    action :install
  end

  gusztavvargadr_windows_chocolatey_package 'virtio-drivers' do
    action :install
  end
end
