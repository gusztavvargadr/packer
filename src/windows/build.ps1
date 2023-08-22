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

packer validate -var-file="$($workDirectory)/options.pkrvars.hcl" -var configuration="$($configuration)" -var provider="$($provider)" -only="$($build).*" $scriptDirectory
packer build  -var-file="$($workDirectory)/options.pkrvars.hcl" -var configuration="$($configuration)" -var provider="$($provider)" -only="$($build).*" -force $scriptDirectory
