include_recipe 'gusztavvargadr_packer_w::patch'

# powershell_script 'Enable AutoLogon' do
#   code <<-EOH
#     reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" /v DefaultUserName /t REG_SZ /d vagrant /f
#     reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" /v DefaultPassword /t REG_SZ /d vagrant /f
#     reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
#     reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" /v AutoLogonCount /t REG_DWORD /d 1 /f
#   EOH
#   action :run
# end
