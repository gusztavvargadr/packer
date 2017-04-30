name 'gusztavvargadr_packer_iis'
description 'Packer IIS'
run_list 'recipe[gusztavvargadr_packer_iis::default]'
default_attributes(
  'gusztavvargadr_packer_iis' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
