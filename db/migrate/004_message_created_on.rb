class MessageCreatedOn < ActiveRecord::Migration
  def self.up
     add_column :messages, "created_on", :datetime
  end

  def self.down
  end
end
