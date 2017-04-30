action :install do
  sp1_installer_file_source = node['gusztavvargadr_packer_vs']['2010_sp1']['installer_file_url']
  windows_package 'Visual Studio 2010 SP1' do
    source sp1_installer_file_source
    installer_type :custom
    options '/q'
    timeout 1800
    returns [0, 3010]
    action :install
  end
end
