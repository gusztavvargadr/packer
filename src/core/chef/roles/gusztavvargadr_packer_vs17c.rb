name 'gusztavvargadr_packer_vs17c'
description 'Packer Visual Studio 2017 Community'
run_list 'recipe[gusztavvargadr_packer_vs17c::default]'
default_attributes(
  'gusztavvargadr_packer_vs17c' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
