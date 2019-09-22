# powershell_script 'Execute NGen' do
#   code <<-EOH
#     Get-ChildItem $env:SystemRoot\\Microsoft.net\\NGen.exe -recurse | %{ & $_ executeQueuedItems }
#   EOH
#   action :run
# end

gusztavvargadr_windows_updates '' do
  action :cleanup
end

gusztavvargadr_windows_powershell_script_elevated 'Clearing temporary files' do
  code <<-EOH
    @(
        "$env:localappdata\\temp\\*",
        "$env:windir\\temp\\*",
        "$env:windir\\logs",
        "$env:windir\\panther",
        "$env:windir\\winsxs\\manifestcache",
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

gusztavvargadr_windows_powershell_script_elevated 'Optimizing volume' do
  code <<-EOH
    Optimize-Volume -DriveLetter C
  EOH
  action :run
end

gusztavvargadr_windows_powershell_script_elevated 'Zeroing volume' do
  code <<-EOH
    sdelete -nobanner -p 3 -z C:
  EOH
  action :run
end
