# powershell_script 'Execute NGen' do
#   code <<-EOH
#     Get-ChildItem $env:SystemRoot\\Microsoft.net\\NGen.exe -recurse | %{ & $_ executeQueuedItems }
#   EOH
#   action :run
# end

gusztavvargadr_windows_updates '' do
  action :cleanup
end

powershell_script 'Optimizing volume' do
  code <<-EOH
    Optimize-Volume -DriveLetter C
  EOH
  action :run
end

powershell_script 'Zeroing volume' do
  code <<-EOH
    sdelete -nobanner -p 3 -z C:
  EOH
  action :run
end
