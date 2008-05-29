class Imagedatefix < ActiveRecord::Migration
  def self.up
    
    Post.find(:all, :conditions => ["created_on > ?", 5.months.ago]).each { |post|
     
     if post.images.length > 0 
      for image in post.images
       image.created_on = post.created_on
       image.save
      end 
     end

     }
 
  end

  def self.down
  end
end
