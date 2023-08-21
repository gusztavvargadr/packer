$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$configuration = $args[0]
$provider = $args[1]
$build = $args[2]

packer init .

pushd ./chef/
chef install
chef export ./artifacts/ --force
popd

packer validate -var-file="./options.pkrvars.hcl" -var configuration="$($configuration)" -var provider="$($provider)" -only="$($build).*" .
packer build  -var-file="./options.pkrvars.hcl" -var configuration="$($configuration)" -var provider="$($provider)" -only="$($build).*" -force .
