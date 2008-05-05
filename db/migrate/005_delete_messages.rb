class DeleteMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :deleted, :boolean, :default => false
  end

  def self.down
  end
end
