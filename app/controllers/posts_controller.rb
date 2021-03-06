class PostsController < ApplicationController

  before_filter :protect, :except => [ :index, :show, :posts_by, :imagebrowser, :random, :updated ]
  before_filter :find_and_protect_post, :except => [ :index, :new, :create, :add_image, :remove_new_image, :show, :posts_by, :imagebrowser, :random, :updated ]

  def find_and_protect_post
    @post = Post.find(params[:id])
    raise "shit!hack" unless @post.user_id == session[:user_id]
  end

  def imagebrowser
    @images = Image.paginate(:all, :page => params[:page], :per_page => 40, :order => "images.created_on desc")
    @title = "rawdod"
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @posts.to_xml }
    end
  end


  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.paginate(:all, :page => params[:page], :per_page => 20, :order => "posts.created_on desc, comments.created_on", :include => [ :comments, :user ])
    @title = "rawdod"
#    @hotness = Post.find(:all, :order => "commented_on desc", :limit => 8, :conditions => ["commented_on is NOT NULL"])
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @posts.to_xml }
    end
  end

  def updated
    @posts = Post.paginate(:all, :page => params[:page], :per_page => 20, :order => "posts.commented_on desc, comments.created_on", :conditions => "posts.commented_on > '2005-11-07 19:22:40'", :include => [ :comments, :user ])
    @title = "rawdod"
    respond_to do |format|
      format.html { render :action => "index" }# index.rhtml
      format.xml  { render :xml => @posts.to_xml }
    end
  end

  def posts_by
    if user = User.find_by_login(params[:user])
    @posts = Post.paginate(:all, :page => params[:page], :per_page => 20, :conditions => ["posts.user_id = ?", user.id ], :order => "posts.created_on desc, comments.created_on", :include => [ :comments, :user ])
    @title = "#{params[:user]} - rawdod"
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

  def random
    @post = Post.find(:first, :order => "random()")
    @title = @post.title
    render :action => "show"
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
         counter = 0
         for image in params[:images]["file_data"]
          if image != ""
           @image = Image.create(:file_data => image, :owner_id => @post.id, :owner_type => 'Post',  :filename => image.original_filename, 
                                 :body => params[:images]["body"][counter] )
           counter = counter + 1
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
         counter = 0
         for image in params[:images]["file_data"]
          if image != ""
           @image = Image.create(:file_data => image, :owner_id => @post.id, :owner_type => 'Post', :filename => image.original_filename, 
                                 :body => params[:images]["body"][counter] )
           counter = counter + 1
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


  def edit_image_description
   case request.method
   when :post
    @image = Image.find(params[:image_id])
    if params[:image]
       @image.body = params[:image][:description]
       @image.save
    else
       render :partial => "edit_image_description", :locals => { :image => @image, :post => @post }
    end 
    end
  end

  def image_description
   case request.method
   when :post
     @image = Image.find(params[:image_id])
     render :partial => "image_description", :locals => { :image => @image, :post => @post }
   end 
  end

end
