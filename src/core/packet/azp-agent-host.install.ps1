#ps1_sysnative

# PowerShell
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

Set-ExecutionPolicy RemoteSigned -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Chef Client
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 17.3.48
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "User")

# Windows
Set-MpPreference -DisableRealtimeMonitoring $True -ExclusionPath "C:\"

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /d 1 /t REG_DWORD /f /reg:64
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /d 2 /t REG_DWORD /f /reg:64

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f

netsh advfirewall set allprofiles settings inboundusernotification enable

## TODO windows update install
## TODO windows update cleanup

# Chocolatey
$env:chocolateyVersion = '0.10.15'
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

# Workstation
choco install -y microsoft-edge
choco install -y conemu
choco install -y far
choco install -y treesizefree
choco install -y vscode
choco install -y beyondcompare

# Development
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /NoAutoCrlf /NoShellIntegration /SChannel'"
choco install -y poshgit
choco install -y dotnetcore-sdk

# Chef Workstation
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef-workstation -version 21.8.555

# Vagrant
choco install -y vagrant --version 2.2.18 --ignore-checksums --ignore-package-exit-codes
# C:\HashiCorp\Vagrant\embedded\gems\2.2.18\gems\vagrant-2.2.18\bin\vagrant
# Encoding.default_external = Encoding.find('Windows-1250')
# Encoding.default_internal = Encoding.find('Windows-1250')

## TODO boxes

# Packer
choco install -y packer --version 1.7.4
[Environment]::SetEnvironmentVariable("PACKER_CACHE_DIR", "%USERPROFILE%\.packer\cache", "User")

## TODO: adk (oscdimg)
## TODO download ISOs

## TODO docker, config and base images
## TODO compose

# Hyper-V
Get-WindowsOptionalFeature -Online | Where { $_.FeatureName -match "hyper" } | Where { $_.State -ne "Enabled" } | ForEach { Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All -NoRestart }
# New-VMSwitch -SwitchName "Default Switch" -SwitchType Internal
# New-NetIPAddress -IPAddress 192.168.238.1 -PrefixLength 24 -InterfaceAlias "vEthernet (Default Switch)"
# New-NetNat -Name "Default Switch" -InternalIPInterfaceAddressPrefix 192.168.238.0/24

## TODO Configure NAT external addresses

Get-WindowsOptionalFeature -Online | Where { $_.FeatureName -match "dhcp" } | Where { $_.State -ne "Enabled" } | ForEach { Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All -NoRestart }
# Add-DhcpServerv4Scope -Name "192.168.238.0/24" -StartRange 192.168.238.100 -EndRange 192.168.238.199 -SubnetMask 255.255.255.0 -LeaseDuration "04:00:00"
# Set-DhcpServerv4OptionValue -ScopeId 192.168.238.0 -OptionId 3 -Value 192.168.238.1
# Set-DhcpServerv4OptionValue -ScopeId 192.168.238.0 -OptionId 6 -Value 8.8.8.8,8.8.4.4

[Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "hyperv", "User")
## TODO kitchen-hyperv, kitchen-docker

# AZP Agent
# wget https://vstsagentpackage.azureedge.net/agent/2.190.0/vsts-agent-win-x64-2.190.0.zip -OutFile vsts-agent.zip
# [Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_URL", "https://dev.azure.com/gusztavvargadr/", "User")
# [Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_AUTH", "pat", "User")

# [Environment]::SetEnvironmentVariable("AZP_AGENT_WINDOWS", "latest", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_DOTNET", "latest", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_CHEF", "latest", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_VAGRANT", "latest", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_PACKER", "latest", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_DOCKER", "latest", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_HYPERV", "latest", "User")

## TODO Configure agents
