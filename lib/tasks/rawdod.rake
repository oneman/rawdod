namespace :rawdod do
 
desc "Resize all uploaded images"
task :resize_all_images  => [:environment] do 
 Image.find(:all).each { |image| image.create_resized_versions }
end
end


