class Post < ActiveRecord::Base
   belongs_to :user
   has_many :comments, :order => "created_on"
end
