class PostsController < ApplicationController

  #before_filter :protect
  
  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.find(:all, :order => "created_on desc")
    @title = "rawdod"

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @posts.to_xml }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])
    @title = @post.title
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @post.to_xml }
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
    @title = "Add a new post"
  end

  # GET /posts/1;edit
  def edit
    @post = Post.find(params[:id])
    @title = "Edit #{@post.title}"
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])
    @post.blog = @blog
    
    respond_to do |format|
      if @post.duplicate? or @blog.posts << @post 
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to post_url(:id => @post) }
        format.xml  { head :created, :location => post_url(:id => @post) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors.to_xml }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to post_url(:id => @post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors.to_xml }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.xml  { head :ok }
    end
  end
  
  private

  # Ensure that user is blog owner, and create @blog.
  def protect_blog
    @blog = Blog.find(params[:blog_id])
    user = User.find(session[:user_id])
    unless @blog.user == user
      flash[:notice] = "That isn't your blog!"
      redirect_to hub_url
      return false
    end
  end
end
