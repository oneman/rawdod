class Image < ActiveRecord::Base

 belongs_to :post
 
   DIRECTORY = 'public/uploaded_images'
   THUMB_MAX_SIZE = 200
   MED_MAX_SIZE = 460
   LARGE_MAX_SIZE = 750

   after_create :process_upload
   after_destroy :remove


   def validate
      errors.add_to_base "File Must be a .jpg or .png file!" if !self.proper_ext?
   end

   def proper_ext?
     ["jpg", "png"].include? @extension
   end

   def file_data=(file_data)
       @file_data = file_data
       @extension = file_data.original_filename.split('.').last.downcase
   end

   def original
       url("original")
   end

   def url(version="large",secondtry=false)
     filename = Dir[File.join(DIRECTORY, "#{self.id}-#{version}*")].first

      url = "#{filename.sub(/^public/,'')}" rescue nil

      if secondtry == false
        if url != nil
          return url
        else
          self.create_resized_versions
          url(version,true) 
        end
      else
        if url != nil
          return url
        else
          return "/images/warn.gif"
        end
      end
   end

   def thumbnail_url
     url("thumb")
   end

   def path 
     # `ls #{DIRECTORY}/#{self.id.to_s}-original*`.chop
     Dir[File.join(DIRECTORY, "#{self.id}-original*")].first
   end

   def delete_resized_versions
     Dir[File.join(DIRECTORY, "#{self.id}-*")].each do |filename|
       unless filename.include? "#{self.id}-original"
        File.unlink(filename) rescue nil
       end
     end
   end

   def create_resized_versions
     original = path
     `convert #{original} -resize #{THUMB_MAX_SIZE}x #{original.sub("original","thumb")}`
     `convert #{original} -resize #{LARGE_MAX_SIZE}x #{original.sub("original","large")}`
     `convert #{original} -resize #{MED_MAX_SIZE}x #{original.sub("original","med")}`
   end

   private

   def process_upload
     if @file_data
       save_original
       create_resized_versions
       @file_data = nil
     end
   end

   def remove
     Dir[File.join(DIRECTORY, "#{self.id}-*")].each do |filename|
       File.unlink(filename) rescue nil
     end
   end

   def save_original
     File.open("#{DIRECTORY}/#{self.id}-original.#{@extension}", 'wb') do |file|
       file.puts @file_data.read
     end
   end


end
