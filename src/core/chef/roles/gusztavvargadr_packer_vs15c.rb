name 'gusztavvargadr_packer_vs15c'
description 'Packer Visual Studio 2015 Community'
run_list 'recipe[gusztavvargadr_packer_vs15c::default]'
default_attributes(
  'gusztavvargadr_packer_vs15c' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
