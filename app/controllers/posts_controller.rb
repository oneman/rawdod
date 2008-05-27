class PostsController < ApplicationController

  before_filter :protect, :except => [ :index, :show, :posts_by ]
  before_filter :find_and_protect_post, :except => [ :index, :new, :create, :add_image, :remove_new_image, :show, :posts_by ]

  def find_and_protect_post
    @post = Post.find(params[:id])
    raise "shit!hack" unless @post.user_id == session[:user_id]
  end

  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.paginate(:all, :page => params[:page], :per_page => 20, :order => "posts.created_on desc, comments.created_on", :include => [ :comments, :user ])
    @title = "rawdod"
    @hotness = Post.find(:all, :order => "commented_on desc", :limit => 8, :conditions => ["commented_on is NOT NULL"])
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @posts.to_xml }
    end
  end

  def posts_by
    if user = User.find_by_login(params[:user])
    @posts = Post.paginate(:all, :page => params[:page], :per_page => 20, :conditions => ["posts.user_id = ?", user.id ], :order => "posts.created_on desc, comments.created_on", :include => [ :comments, :user ])
    @title = "rawdod"
    @hotness = []
       flash[:notice] = "Viewing posts by #{params[:user]}"
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @posts.to_xml }
    end
    else
       flash[:notice] = "Can't find a user called #{params[:user]}"
       redirect_to :action => 'index'
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
    @post.user_id = session[:user_id]
    
    respond_to do |format|
      if @post.save
        flash[:notice] = 'Post was successfully created.'
        
        if params[:images]
         for image in params[:images]["file_data"]
          if image != ""
           @image = Image.create(:file_data => image, :post_id => @post.id, :filename => image.original_filename )
          end
         end
        end
        
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
        
        if params[:images]
         for image in params[:images]["file_data"]
          if image != ""
           @image = Image.create(:file_data => image, :post_id => @post.id, :filename => image.original_filename )
          end
         end
        end
        
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
  
  
  # Image Stuff
  
  def add_image
     params[:type] ||= "new_image"
     @type = params[:type]
  end
  
  def remove_image
    if request.method == :delete
      @image = Image.find(params[:image_id]).destroy
    end
  end
  
  def remove_new_image
  end

  def sort_images
    @post.images.each do |image| 
      image.position = params['post_images'].index(image.id.to_s) + 1
      image.save 
    end 
   render :nothing => true
  end

end
