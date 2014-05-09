execute 'pkg set-publisher -g http://pkg.omniti.com/omniti-ms/ ms.omniti.com' do
  not_if 'pkg publisher ms.omniti.com'
end

execute 'pkg refresh --full'
