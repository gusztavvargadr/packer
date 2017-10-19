powershell_script 'Set service \'WinRM\' to \'Autostart\'' do
  code 'sc.exe config winrm start= auto'
  action :run
end

powershell_script 'Execute NGen' do
  code <<-EOH
    Get-ChildItem $env:SystemRoot\\Microsoft.net\\NGen.exe -recurse | %{ & $_ executeQueuedItems }
  EOH
  action :run
end

gusztavvargadr_windows_updates '' do
  action [:cleanup]
end

gusztavvargadr_windows_powershell_script_elevated 'Clearing temporary files' do
  code <<-EOH
    @(
        "$env:localappdata\\Nuget",
        "$env:localappdata\\temp\\*",
        "$env:windir\\logs",
        "$env:windir\\panther",
        "$env:windir\\temp\\*",
        "$env:windir\\winsxs\\manifestcache",
        "$env:windir\\SoftwareDistribution\\Download\\*"
    ) | % {
            if(Test-Path $_) {
                Write-Host "Removing $_"
                try {
                  Takeown /d Y /R /f $_
                  Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
                  Remove-Item $_ -Recurse -Force | Out-Null
                } catch { $global:error.RemoveAt(0) }
            }
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

powershell_script 'Zeroing volume' do
  code <<-EOH
    Write-Host "Wiping empty space on disk..."
    $FilePath="c:\\zero.tmp"
    $Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
    $ArraySize= 64kb
    $SpaceToLeave= $Volume.Size * 0.001
    $FileSize= $Volume.FreeSpace - $SpacetoLeave
    $ZeroArray= new-object byte[]($ArraySize)

    $Stream= [io.File]::OpenWrite($FilePath)
    try {
      $CurFileSize = 0
        while($CurFileSize -lt $FileSize) {
            $Stream.Write($ZeroArray,0, $ZeroArray.Length)
            $CurFileSize +=$ZeroArray.Length
        }
    }
    finally {
        if($Stream) {
            $Stream.Close()
        }
    }
    Del $FilePath
  EOH
  action :run
end

gusztavvargadr_windows_updates '' do
  action [:disable]
end

gusztavvargadr_windows_pagefile '' do
  action :enable
end
