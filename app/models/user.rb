require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base

  # Please change the salt to something else, 
  # Every application should use a different one 
  @@salt = 'funtocrack'
  cattr_accessor :salt
  attr_accessor :remember_me, :current_password
  # Authenticate a user. 
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    find(:first, :conditions => ["login = ? AND password = ?", login, sha1(pass)])
  end  
  

  def has_custom_css?
   if css != "" && css != nil
    return true
   end
   false
  end

  #protected

  # Apply SHA1 encryption to the supplied password. 
  # We will additionally surround the password with a salt 
  # for additional security. 
  def self.sha1(pass)
    Digest::SHA1.hexdigest("#{salt}--#{pass}--")
  end
    
  before_create :crypt_password
  
  # Before saving the record to database we will crypt the password 
  # using SHA1. 
  # We never store the actual password in the DB.
  def crypt_password
    write_attribute "password", self.class.sha1(password)
  end
  

  
  validates_uniqueness_of :login, :on => :create

  validates_confirmation_of :password, :on => :create
  validates_length_of :login, :within => 3..20
  validates_length_of :password, :within => 4..40
  validates_presence_of :login, :password, :password_confirmation, :on => :create
  validates_format_of :login, 
                      :with => /^[A-Z0-9_]*$/i, 
                      :message => "must contain only letters, " + 
                                  "numbers, and underscores"

  # Log a user in.
  def login!(session)
    session[:user_id] = id
    session[:user_login] = login
    if self.has_custom_css?
     session[:custom_css] = true
    else
     sesion[:custom_css] = false
    end
    self.seen_on = Time.now
    save!
  end
  
  # Log a user out.
  def self.logout!(session, cookies)
    session[:user_id] = nil
    cookies.delete(:authorization_token)
  end
  
  # Clear the password (typically to suppress its display in a view).
  def clear_password!
    self.password = nil
    self.password_confirmation = nil
    self.current_password = nil
  end
  
  # Remember a user for future login.
  def remember!(cookies)
    cookie_expiration = 10.years.from_now
    cookies[:remember_me] = { :value   => "1",
                              :expires =>  cookie_expiration }
    self.authorization_token =  unique_identifier
    save!
    cookies[:authorization_token] = { :value   => authorization_token,
                                      :expires => cookie_expiration }
  end
  
  # Forget a user's login status.
  def forget!(cookies)
    cookies.delete(:remember_me)
    cookies.delete(:authorization_token)
  end

  # Return true if the user wants the login status remembered.
  def remember_me?
    remember_me == "1"
  end

  private
  
  # Generate a unique identifier for a user.
  def unique_identifier
    Digest::SHA1.hexdigest("#{login}:#{password}")
  end
end
