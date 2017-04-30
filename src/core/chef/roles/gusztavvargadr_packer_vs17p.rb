name 'gusztavvargadr_packer_vs17p'
description 'Packer Visual Studio 2017 Professional'
run_list 'recipe[gusztavvargadr_packer_vs17p::default]'
default_attributes(
  'gusztavvargadr_packer_vs17p' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
