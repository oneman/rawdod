class Post < ActiveRecord::Base
   belongs_to :user
   has_many :comments, :order => "created_on", :dependent => :destroy
   has_many :images, :order => "position", :dependent => :destroy

  def authorized?(userid)
    if (self.user_id == userid) && editable?
      return true
    else
      return false
    end
  end

  def editable?
     return true if created_on > 300.minutes.ago
     false
  end

end
