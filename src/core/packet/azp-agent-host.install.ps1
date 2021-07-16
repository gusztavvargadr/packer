#ps1_sysnative

# PowerShell
$ErrorActionPreference = "Stop"

Set-ExecutionPolicy RemoteSigned -Force
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

# Chef Client
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 17.2.29
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")

# Workstation
choco install -y googlechrome
# choco install -y firefox --params "/NoAutoUpdate"
choco install -y conemu
choco install -y far
choco install -y treesizefree
choco install -y vscode
choco install -y beyondcompare

# Development
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /NoAutoCrlf /NoShellIntegration /SChannel'"
choco install -y poshgit
choco install -y dotnetcore-sdk
& 'C:\Program Files\dotnet\dotnet.exe' tool install Cake.Tool --global

# Hyper-V
Get-WindowsOptionalFeature -Online | Where { $_.FeatureName -match "hyper" } | Where { $_.State -ne "Enabled" } | ForEach { Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All -NoRestart }
# New-VMSwitch -SwitchName HyperVNAT -SwitchType Internal
# New-NetIPAddress -IPAddress 192.168.238.1 -PrefixLength 24 -InterfaceAlias "vEthernet (HyperVNAT)"
# New-NetNat -Name HyperVNAT -InternalIPInterfaceAddressPrefix 192.168.238.0/24
# [Environment]::SetEnvironmentVariable("HYPERV_DEFAULT_SWITCH", "HyperVNAT", "Machine")

## TODO Configure NAT external addresses

Get-WindowsOptionalFeature -Online | Where { $_.FeatureName -match "dhcp" } | Where { $_.State -ne "Enabled" } | ForEach { Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All -NoRestart }
# Add-DhcpServerv4Scope -Name "192.168.238.0/24" -StartRange 192.168.238.100 -EndRange 192.168.238.199 -SubnetMask 255.255.255.0 -LeaseDuration "04:00:00"
# Set-DhcpServerv4OptionValue -ScopeId 192.168.238.0 -OptionId 3 -Value 192.168.238.1
# Set-DhcpServerv4OptionValue -ScopeId 192.168.238.0 -OptionId 6 -Value 8.8.8.8,8.8.4.4

# VirtualBox
# choco install -y virtualbox --version 6.1.22 --params "/ExtensionPack"
# bcdedit /set hypervisorlaunchtype off

# Vagrant
choco install -y vagrant --version 2.2.16 --ignore-package-exit-codes
# C:\HashiCorp\Vagrant\embedded\gems\2.2.16\gems\vagrant-2.2.16\bin\vagrant
# Encoding.default_external = Encoding.find('Windows-1250')
# Encoding.default_internal = Encoding.find('Windows-1250')
[Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "hyperv", "Machine")
# [Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "virtualbox", "Machine")

## TODO boxes

# Packer
choco install -y packer --version 1.7.2
[Environment]::SetEnvironmentVariable("PACKER_CACHE_DIR", "%USERPROFILE%\.packer\cache", "Machine")
# [Environment]::SetEnvironmentVariable("PACKER_VAR_hyperv_switch_name", "%HYPERV_DEFAULT_SWITCH%", "Machine")

## TODO: adk (oscdimg)
## TODO download ISOs

# Chef Workstation
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef-workstation -version 21.6.497
# [Environment]::SetEnvironmentVariable("KITCHEN_HYPERV_SWITCH", "%HYPERV_DEFAULT_SWITCH%", "Machine")

## TODO kitchen, kitchen-docker
## TODO docker, config and base images
## TODO compose

# AZP Agent
# wget https://vstsagentpackage.azureedge.net/agent/2.188.3/vsts-agent-win-x64-2.188.3.zip -OutFile vsts-agent.zip
# [Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_URL", "https://dev.azure.com/gusztavvargadr/", "User")
# [Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_AUTH", "pat", "User")
# [Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_TOKEN", "Token42-", "User")

# [Environment]::SetEnvironmentVariable("AZP_AGENT_WINDOWS", "1809", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_HYPERV", "9.0", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_VIRTUALBOX", "6.1.22", "User")
# [Environment]::SetEnvironmentVariable("AZP_AGENT_DOCKER", "", "User")

## TODO Configure agents
