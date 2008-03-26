namespace :rawdod do
namespace :import do

desc "import homepages"
task :import_homepages  => [:environment] do

 homepages = YAML.load_file("/home/rawdod/rawdod_homepages.yml")

for homepage in homepages

user = nil
user = User.find_by_login(homepage.first)
if user 
puts "found user" + user.login
user.homepage = homepage.last
puts user.homepage
user.save
else
puts "Shit"
end

end

end

end
end

