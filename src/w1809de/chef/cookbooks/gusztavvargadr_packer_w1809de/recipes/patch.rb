# gusztavvargadr_windows_updates 'http://download.windowsupdate.com/d/msdownload/update/software/crup/2018/07/windows10.0-kb4343669-x64_2a58320e44d3ff803bc7016b5d02f3e85482b46f.msu' do
#   action :install
# end

# gusztavvargadr_windows_updates 'http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/07/windows10.0-kb4338819-x64_73cef45cbee3c689ddddf596aed7cb6a61092180.msu' do
#   action :install
# end

include_recipe 'gusztavvargadr_packer_w::patch'
