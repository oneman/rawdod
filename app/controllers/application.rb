# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ApplicationHelper
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_rawdod_session_id'

  layout "standard"
  
  before_filter :check_authorization
  
  # Log a user in by authorization cookie if necessary.
  def check_authorization
    authorization_token = cookies[:authorization_token]
    if authorization_token and not logged_in?
      user = User.find_by_authorization_token(authorization_token)
      user.login!(session) if user
    end
  end

end
