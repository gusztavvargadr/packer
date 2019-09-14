include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_windows_updates '' do
  msu_source 'http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/09/windows10.0-kb4512574-x64_70c6d50fa9b65aa7f7a1202145185f244f8425c7.msu'
  action :install
end
