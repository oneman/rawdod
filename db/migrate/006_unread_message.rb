class UnreadMessage < ActiveRecord::Migration
  def self.up
    add_column :users, :unread_message, :boolean, :default => false
  end

  def self.down
  end
end
