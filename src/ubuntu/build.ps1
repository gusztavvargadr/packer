$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$scriptDirectory = $PSScriptRoot
$workDirectory = $pwd

$image = $args[0]
$provider = $args[1]
$build = $args[2]

packer init $scriptDirectory
# packer init -upgrade $scriptDirectory

# packer console  -var-file="$($workDirectory)/images.pkrvars.hcl" -var image="$($image)" -var provider="$($provider)" -var build="$($build)" $scriptDirectory
# exit

packer validate -var-file="$($workDirectory)/images.pkrvars.hcl" -var image="$($image)" -var provider="$($provider)" -var build="$($build)" -only "$($build)-restore.*" $scriptDirectory
packer build  -var-file="$($workDirectory)/images.pkrvars.hcl" -var image="$($image)" -var provider="$($provider)" -var build="$($build)" -only "$($build)-restore.*" -force $scriptDirectory

packer validate -var-file="$($workDirectory)/images.pkrvars.hcl" -var image="$($image)" -var provider="$($provider)" -var build="$($build)" -only "$($build)-image.*" $scriptDirectory
packer build  -var-file="$($workDirectory)/images.pkrvars.hcl" -var image="$($image)" -var provider="$($provider)" -var build="$($build)" -only "$($build)-image.*" -force $scriptDirectory
