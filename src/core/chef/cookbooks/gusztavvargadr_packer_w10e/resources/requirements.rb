property :requirements_options, Hash

default_action :ensure

action :ensure do
  return if requirements_options.nil?

  gusztavvargadr_packer_core_requirements '' do
    requirements_options new_resource.requirements_options
    action :ensure
  end

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

  gusztavvargadr_windows_windows_defender '' do
    action :disable
  end

  powershell_script 'Disable Scheduled Defrag' do
    code 'Schtasks.exe /change /disable /tn "\Microsoft\Windows\Defrag\ScheduledDefrag"'
    action :run
  end
end
