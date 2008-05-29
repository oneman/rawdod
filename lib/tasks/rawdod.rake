namespace :rawdod do
 
desc "Resize all uploaded images"
task :resize_all_images  => [:environment] do 
 Image.find(:all).each { |image| image.create_resized_versions }
end


desc "Resize images needing resize"
task :resize_images_that_need_it  => [:environment] do 
 Image.find(:all).each { |image| 

#puts image.filename
monkey = image.url

if image.url.include? "broken"
puts "FUUUUUUUUUUUUUUUUUUUUUUUUUCK" + image.id.to_s
end

 }

end



end


