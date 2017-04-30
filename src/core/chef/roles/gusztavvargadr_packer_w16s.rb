name 'gusztavvargadr_packer_w16s'
description 'Packer Windows Server 2016 Standard'
run_list 'recipe[gusztavvargadr_packer_w::default]',
  'recipe[gusztavvargadr_packer_w16s::default]'
default_attributes(
  'gusztavvargadr_packer_w' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  },
  'gusztavvargadr_packer_w16s' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
