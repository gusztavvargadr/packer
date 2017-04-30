name 'gusztavvargadr_packer_w12r2s'
description 'Packer Windows Server 2012 R2 Standard'
run_list 'recipe[gusztavvargadr_packer_w::default]',
  'recipe[gusztavvargadr_packer_w12r2s::default]'
default_attributes(
  'gusztavvargadr_packer_w' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  },
  'gusztavvargadr_packer_w12r2s' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
