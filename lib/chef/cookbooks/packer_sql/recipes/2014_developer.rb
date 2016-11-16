packer_sql_2014_prerequisites '' do
  action :install
end

packer_sql_2014 'developer' do
  action :install
end
