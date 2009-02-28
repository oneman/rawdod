class Comment < ActiveRecord::Base

belongs_to :post
belongs_to :user
has_one :image, :as => :owner, :dependent => :destroy

  validates_presence_of :body, :post, :user

  # Prevent duplicate comments.
  validates_uniqueness_of :body, :scope => [:post_id, :user_id]

  # Return true for a duplicate comment (same user and body).
  def duplicate?
    c = Comment.find_by_post_id_and_user_id_and_body(post, user, body)
    # Give self the id for REST routing purposes.
    self.id = c.id unless c.nil?
    not c.nil?
  end
  
  # Check authorization for destroying comments.
  def authorized?(userid)
    if (self.user_id == userid) && editable?
      return true
    else
      return false
    end
  end

  def editable?
     return true if created_on > 95.minutes.ago
     false
  end

end
