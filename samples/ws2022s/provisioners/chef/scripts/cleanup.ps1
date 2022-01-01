# Write-Host "Install OpenSSH"
# netsh advfirewall firewall add rule name="OpenSSH-Install" dir=in localport=22 protocol=TCP action=block
# choco install openssh -y --version 8.0.0.1 -params '"/SSHServerFeature"' # /PathSpecsToProbeForShellEXEString:$env:windir\system32\windowspowershell\v1.0\powershell.exe"'
# net stop sshd
# netsh advfirewall firewall delete rule name="OpenSSH-Install"

# Write-Host "Configure OpenSSH"
# $sshd_config = "$($env:ProgramData)\ssh\sshd_config"
# (Get-Content $sshd_config).Replace("Match Group administrators", "# Match Group administrators") | Set-Content $sshd_config
# (Get-Content $sshd_config).Replace("AuthorizedKeysFile", "# AuthorizedKeysFile") | Set-Content $sshd_config
# net start sshd
