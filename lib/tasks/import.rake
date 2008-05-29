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



 
 










desc "import contents"
task :import_content  => [:environment] do

contents = YAML.load_file("/home/rawdod/rawdod_content.yml")

for c in contents

content = c.first
comments = c.last

user = User.find(content[0])

if user
title = content[1]
body = content[2]

created_on = Time.at(content[3].to_i)

#puts "#{message} from #{from_user.login} to #{to_user.login} on #{created_on}"
newpost = Post.new(:created_on => created_on, :body => body, :title => title, :user_id => user.id)

raise "hell" unless newpost.valid?


if title.length > 250
puts "fucked"
next
end

newpost.save
post_id = newpost.id
# save post here



for comment in comments
#puts comment

if comment[1] == ""
puts "skipped emty comment"
puts comment
next
end

if comment[1].class.to_s != "Fixnum"

comment_created_on = Time.at(comment[2].to_i)
puts comment[2]
comment_user_id = User.find(comment[0].to_i).id 


else
puts "cant find user#{comment[0]}"
next
end

newcomment = Comment.new(:post_id => post_id, :user_id => comment_user_id, :body => comment[1], :created_on => comment_created_on)

if comment[1] != ""
puts "dupe comment #{comment[1]}"  unless newcomment.valid?
end
if comment[1] != "" && newcomment.valid?
 newcomment.save
end

end

else
puts "wacked #{c[1]}"
end

end

end





desc "import images"
task :import_images  => [:environment] do

contents = YAML.load_file("/home/rawdod/rawdod_images.yml")

for c in contents

content = c.first
comments = c.last

user = User.find(content[0])

if user
title = content[1]
body = content[2]
oldid = content[4]
created_on = Time.at(content[3].to_i)

#puts "#{message} from #{from_user.login} to #{to_user.login} on #{created_on}"
newpost = Post.new(:created_on => created_on, :body => body, :title => title, :user_id => user.id)

raise "hell" unless newpost.valid?


if title.length > 250
puts "fucked"
next
end

newpost.save
post_id = newpost.id
# save post here


image = Image.create(:post_id => newpost.id, :filename => newpost.title, :oldid => oldid, :created_on => created_on )
if image.save

#puts "saved #{newpost.title}"

else
puts newpost.title

puts image.errors.full_messages

raise "fucked"
end

extension = newpost.title.split(".").last.downcase

DIRECTORY = "/home/rawdod/rawdod/public/uploaded_images"

if oldid.to_i > 2593

`cp -v /home/rawdod/rawdod_sept2007/public/image/file/#{oldid}/#{newpost.title.dump} #{DIRECTORY}/#{image.id}-original.#{extension}`
else

#imagenamefix = newpost.title.split(".").first + "-large." + newpost.title.split(".").last 
imagenamefix = newpost.title
`cp -v /home/oneman/Desktop/user_images/#{imagenamefix.dump} #{DIRECTORY}/#{image.id}-original.#{extension}`

end

#image.create_resized_versions

for comment in comments
#puts comment

if comment[1] == ""
puts "skipped emty comment"
puts comment
next
end

if comment[1].class.to_s != "Fixnum"

comment_created_on = Time.at(comment[2].to_i)
#puts comment[2]
comment_user_id = User.find(comment[0].to_i).id 


else
puts "cant find user#{comment[0]}"
next
end

newcomment = Comment.new(:post_id => post_id, :user_id => comment_user_id, :body => comment[1], :created_on => comment_created_on)

if comment[1] != ""
puts "dupe comment #{comment[1]}"  unless newcomment.valid?
end
if comment[1] != "" && newcomment.valid?
 newcomment.save
end

end

else
puts "wacked #{c[1]}"
end

end

end













end
end

