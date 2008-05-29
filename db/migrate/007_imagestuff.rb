class Imagestuff < ActiveRecord::Migration
  def self.up
    add_column :images, :created_on, :datetime
    add_column :images, :oldid, :integer

  end

  def self.down
  end
end
