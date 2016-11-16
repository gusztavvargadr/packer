action :install do
  chocolatey_package 'boxstarter.common' do
    action :install
  end

  chocolatey_package 'boxstarter.winconfig' do
    action :install
  end
end

action :uninstall do
  chocolatey_package 'boxstarter.winconfig' do
    action :uninstall
  end

  chocolatey_package 'boxstarter.common' do
    action :uninstall
  end
end
