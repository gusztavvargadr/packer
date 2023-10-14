$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$scriptDirectory = $PSScriptRoot
$workDirectory = $pwd

$configuration = $args[0]
$provider = $args[1]
$build = $args[2]

packer init $scriptDirectory

chef install
chef export ./artifacts/chef/ --force

packer validate -var-file="$($workDirectory)/options.pkrvars.hcl" -var configuration="$($configuration)" -var provider="$($provider)" -var build="$($build)" -except "*.null.*" $scriptDirectory

packer build  -var-file="$($workDirectory)/options.pkrvars.hcl" -var configuration="$($configuration)" -var provider="$($provider)" -var build="$($build)" -except "*.null.*" -force $scriptDirectory
