class Initial < ActiveRecord::Migration
  def self.up
    create_table "posts" do |t|
      t.column "user_id", :integer
      t.column "title", :string
      t.column "body", :text
      t.column "url", :string
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
      t.column "commented_on", :datetime
    end
    
    create_table "comments" do |t|
      t.column "user_id", :integer
      t.column "post_id", :integer
      t.column "body", :text
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    create_table "messages" do |t|
      t.column "user_id", :integer
      t.column "to_user_id", :integer
      t.column "body", :text
    end

    create_table "images" do |t|
      t.column "post_id", :integer
      t.column "position", :integer
      t.column "filename", :string
      t.column "body", :text
    end
    
    create_table "users" do |t|
      t.column "login", :string
      t.column "password", :string
      t.column "seen_on", :datetime
      t.column "authorization_token", :string
    end
  end

  def self.down
    drop_table "posts"
    drop_table "images"
    drop_table "messages"
    drop_table "comments"
    drop_table "users"
  end
end
