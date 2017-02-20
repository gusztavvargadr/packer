action :run do
  powershell_script 'Execute NGen' do
    code <<-EOH
      Get-ChildItem $env:SystemRoot\\Microsoft.net\\NGen.exe -recurse | %{ & $_ executeQueuedItems }
    EOH
    action :run
  end
end
