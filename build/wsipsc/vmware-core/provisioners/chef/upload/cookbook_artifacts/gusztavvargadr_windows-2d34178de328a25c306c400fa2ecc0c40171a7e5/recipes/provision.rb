updates = node['gusztavvargadr_windows']['updates']
updates.each do |update_name, update_options|
  gusztavvargadr_windows_update update_name do
    options update_options
    action update_name.gsub('-', '_')
  end
end

reboot 'gusztavvargadr_windows::provision' do
  action :reboot_now
  only_if { reboot_pending? }
end
