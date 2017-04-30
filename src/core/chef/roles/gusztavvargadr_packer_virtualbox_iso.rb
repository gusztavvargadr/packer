name 'gusztavvargadr_packer_virtualbox_iso'
description 'Packer Virtualbox ISO'
run_list 'recipe[gusztavvargadr_packer_os::default]',
  'recipe[gusztavvargadr_packer_virtualbox::default]'
default_attributes(
  'gusztavvargadr_packer_os' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  },
  'gusztavvargadr_packer_virtualbox' => {
    'requirements' => {},
    'tools' => {},
    'updates' => {},
    'cleanup' => {},
  }
)
