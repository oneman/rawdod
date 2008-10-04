class CustomCss < ActiveRecord::Migration
  def self.up
   add_column :users, "css", :text
  end

  def self.down
  end
end
