# powershell_script 'Execute NGen' do
#   code <<-EOH
#     Get-ChildItem $env:SystemRoot\\Microsoft.net\\NGen.exe -recurse | %{ & $_ executeQueuedItems }
#   EOH
#   action :run
# end

gusztavvargadr_windows_updates '' do
  action [:cleanup, :stop, :disable]
end

powershell_script 'Clearing temporary files' do
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

powershell_script 'Optimizing volume' do
  code <<-EOH
    Optimize-Volume -DriveLetter C
  EOH
  action :run
end

chocolatey_package 'sdelete' do
  version '2.01'
  action :install
end

powershell_script 'Zeroing volume' do
  code <<-EOH
    sdelete -z C:
  EOH
  action :run
end
