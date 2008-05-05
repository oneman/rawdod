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


desc "import msgs"
task :import_msgs  => [:environment] do

 msgs = YAML.load_file("/home/rawdod/rawdod_messages.yml")

for msg in msgs

to_user = User.find(msg[0])
from_user = User.find(msg[1])

if to_user && from_user
message = msg[2]
created_on = Time.at(msg[3].to_i)

#puts "#{message} from #{from_user.login} to #{to_user.login} on #{created_on}"
Message.create(:created_on => created_on, :body => message, :user_id => from_user.id, :to_user_id => to_user.id)
else
puts "wacked #{message}"
end

end

end

end
end

