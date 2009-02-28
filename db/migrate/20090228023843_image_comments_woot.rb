class ImageCommentsWoot < ActiveRecord::Migration
  def self.up
       add_column :images, "owner_type", :string
       rename_column :images, "post_id", "owner_id"
       execute "UPDATE images set owner_type = 'Post'" 
  end

  def self.down
  end
end
