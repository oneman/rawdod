class UserController < ApplicationController

  before_filter :protect, :only => [ :edit_homepage ]

  def signup
    @title = "Register"
    if request.post?
    if params[:robot_check] == "I am human."
      @user = User.new(params[:user])
      if @user.save 
        @user.login!(session)
        flash[:notice] = "User #{@user.login} created!"
        redirect_to "/"
      else
        @user.clear_password!
      end
     else
        flash[:notice] = "DIE ROBOT DIE!"
     end
    end
  end

  def login
    @title = "Log in to Rawdod"
    if request.get?    
      @user = User.new(:remember_me => remember_me_string)
    elsif request.post? 
      @user = User.new(params[:user])
      user = User.authenticate(@user.login,@user.password) 
      if user
        user.login!(session)
        @user.remember_me? ? user.remember!(cookies) : user.forget!(cookies)
        flash[:notice] = "User #{user.login} logged in!"
        redirect_to "/"
      else 
        @user.clear_password!
        flash[:notice] = "Invalid login/password combination"
      end
    end
  end
  
  def logout
    User.logout!(session, cookies)
    flash[:notice] = "Logged out"
    redirect_to "/"
  end

  def remember_me_string
    cookies[:remember_me] || "0"
  end

  def seen
    @users = User.find(:all, :order => "seen_on desc", :conditions => ["seen_on is NOT NULL" ])
  end

  def homepages
    @users = User.find(:all, :order => "login", :conditions => ["homepage is NOT NULL" ])
  end

  def homepage
      @user = User.find_by_login(params[:user])
  end

  def edit_homepage
       @user = User.find(session[:user_id])
      if request.post?
       @user.homepage = params[:homepage]
       @user.save
       redirect_to "/home/" + @user.login
      end
  end

end
