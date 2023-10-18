updates = node['gusztavvargadr_windows']['updates']
updates.each do |update_name, update_options|
  gusztavvargadr_windows_update update_name do
    options update_options
    action :initialize
  end
end
