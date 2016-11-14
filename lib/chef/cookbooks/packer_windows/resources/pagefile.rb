action :enable do
  powershell_script 'Enable Pagefile' do
    code <<-EOH
      $computer = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
      $computer.AutomaticManagedPagefile = $True
      $computer.Put()
    EOH
    action :run
  end
end

action :disable do
  powershell_script 'Disable Pagefile' do
    code <<-EOH
      $computer = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
      $computer.AutomaticManagedPagefile = $False
      $computer.Put()

      $pagefile = Get-WmiObject Win32_PageFileSetting -EnableAllPrivileges
      if ($pagefile) {
        $pagefile.Delete()
      }
    EOH
    action :run
  end
end
