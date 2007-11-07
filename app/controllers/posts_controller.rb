class PostsController < ApplicationController

  before_filter :protect, :except => :index
  before_filter :find_and_protect_post, :except => [ :index, :new, :create ]

  def find_and_protect_post
    @post = Post.find(params[:id])
    raise "shit!hack" unless @post.user_id == session[:user_id]
  end

  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.paginate(:all, :page => params[:page], :per_page => 20, :order => "posts.created_on desc, comments.created_on", :include => [ :comments, :user ])
    @title = "rawdod"

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @posts.to_xml }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
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
    @post.user_id = session[:user_id]
    
    respond_to do |format|
      if @post.save
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to :controller => "posts" }
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

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to posts_path }
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

    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.xml  { head :ok }
    end
  end
  


end
