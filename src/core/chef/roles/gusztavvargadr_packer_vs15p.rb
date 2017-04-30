name 'gusztavvargadr_packer_vs15p'
description 'Packer Visual Studio 2015 Professional'
run_list 'recipe[gusztavvargadr_packer_vs15p::default]'
default_attributes(
  'gusztavvargadr_packer_vs15p' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
