include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_windows_uac '' do
  action :disable
end

gusztavvargadr_windows_remote_desktop '' do
  action :enable
end

# powershell_script 'Disable AppX Update' do
#   code 'Schtasks.exe /change /disable /tn "\Microsoft\Windows\AppxDeploymentClient\Pre-staged app cleanup"'
#   action :run
# end

# powershell_script 'Remove AppX Packages' do
#   code <<-EOH
#     Get-AppxPackage Microsoft.DesktopAppInstaller | Remove-AppxPackage
#     Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
#     Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage
#     Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage
#   EOH
#   action :run
# end

gusztavvargadr_windows_defender '' do
  action :disable
end

powershell_script 'Disable maintenance' do
  code <<-EOH
    reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Schedule\\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f
  EOH
  action :run
end
