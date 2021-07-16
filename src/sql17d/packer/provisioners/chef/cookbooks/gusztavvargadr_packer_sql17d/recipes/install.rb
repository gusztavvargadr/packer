gusztavvargadr_mssql_server '' do
  version '2017'
  edition 'developer'
  action [:install, :patch]
end

gusztavvargadr_mssql_management_studio '' do
  version '2018'
  action :install
end
