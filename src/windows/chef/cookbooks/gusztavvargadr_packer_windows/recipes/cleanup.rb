reboot 'gusztavvargadr_packer_windows::cleanup' do
  delay_mins 1
  action :reboot_now
  only_if { reboot_pending? }
end

powershell_script 'Clearing temporary files' do
  code <<-EOH
    @(
        "$env:localappdata\\temp\\*",
        "$env:windir\\logs",
        "$env:windir\\panther",
        "$env:programdata\\Microsoft\\Windows Defender\\Scans\\*"
        ) | % {
          Write-Host "Removing $_"
          try {
            Takeown /d Y /R /f $_
            Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
            Remove-Item $_ -Recurse -Force | Out-Null
          } catch { $global:error.RemoveAt(0) }
        }
  EOH
  action :run
end

# gusztavvargadr_windows_update '' do
#   action :cleanup
# end

reboot 'gusztavvargadr_packer_windows::cleanup' do
  delay_mins 1
  action :reboot_now
  only_if { reboot_pending? }
end
