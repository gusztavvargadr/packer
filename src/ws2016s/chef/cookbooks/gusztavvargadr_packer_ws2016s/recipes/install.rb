include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_windows_updates '' do
  msu_source 'http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/02/windows10.0-kb4485447-x64_e9334a6f18fa0b63c95cd62930a058a51bba9a14.msu'
  action :install
end
