powershell_script 'Disable AppX Update' do
  code 'Schtasks.exe /change /disable /tn "\Microsoft\Windows\AppxDeploymentClient\Pre-staged app cleanup"'
  action :run
end

powershell_script 'Remove AppX Packages' do
  code <<-EOH
    Get-AppxPackage Microsoft.DesktopAppInstaller | Remove-AppxPackage
    Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
    Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage
    Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage
  EOH
  action :run
end

packer_windows_windows_defender '' do
  action :disable
end
