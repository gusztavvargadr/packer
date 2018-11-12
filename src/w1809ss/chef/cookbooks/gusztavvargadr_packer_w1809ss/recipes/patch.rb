# gusztavvargadr_windows_updates 'http://download.windowsupdate.com/d/msdownload/update/software/crup/2018/07/windows10.0-kb4343669-x64_2a58320e44d3ff803bc7016b5d02f3e85482b46f.msu' do
#   action :install
# end

# gusztavvargadr_windows_updates 'http://download.windowsupdate.com/c/msdownload/update/software/crup/2018/05/windows10.0-kb4132216-x64_9cbeb1024166bdeceff90cd564714e1dcd01296e.msu' do
#   action :install
# end

include_recipe 'gusztavvargadr_packer_w::patch'
