name 'gusztavvargadr_packer_hyperv_iso'
description 'Packer Hyper-V ISO'
run_list 'recipe[gusztavvargadr_packer_os::default]'
default_attributes(
  'gusztavvargadr_packer_os' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  },
)
