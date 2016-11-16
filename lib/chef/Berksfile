source 'https://supermarket.chef.io'

def local_cookbooks(directory_path)
  Dir["#{directory_path}/**"].each do |cookbook_folder_path|
    cookbook File.basename(cookbook_folder_path), path: cookbook_folder_path
  end
end
