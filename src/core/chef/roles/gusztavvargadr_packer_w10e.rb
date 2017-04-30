name 'gusztavvargadr_packer_w10e'
description 'Packer Windows 10 Enterprise'
run_list 'recipe[gusztavvargadr_packer_w::default]',
  'recipe[gusztavvargadr_packer_w10e::default]'
default_attributes(
  'gusztavvargadr_packer_w' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  },
  'gusztavvargadr_packer_w10e' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
