name 'gusztavvargadr_packer_vs10p'
description 'Packer Visual Studio 2010 Professional'
run_list 'recipe[gusztavvargadr_packer_vs10p::default]'
default_attributes(
  'gusztavvargadr_packer_vs10p' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
