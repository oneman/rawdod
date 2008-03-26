class Homepage < ActiveRecord::Migration
  def self.up
    add_column :users, "homepage", :text
  end

  def self.down
  end
end
