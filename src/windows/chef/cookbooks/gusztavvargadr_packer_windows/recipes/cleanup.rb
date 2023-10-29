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
  not_if { reboot_pending? }
end

gusztavvargadr_windows_updates '' do
  action :cleanup
  not_if { reboot_pending? }
end

reboot 'cleanup' do
  action :reboot_now
  only_if { reboot_pending? }
end
