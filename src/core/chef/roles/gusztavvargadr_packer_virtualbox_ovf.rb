name 'gusztavvargadr_packer_virtualbox_ovf'
description 'Packer Virtualbox OVF'
run_list 'recipe[gusztavvargadr_packer_os::default]'
default_attributes(
  'gusztavvargadr_packer_os' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  },
)
