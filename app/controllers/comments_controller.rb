class CommentsController < ApplicationController 
  
  before_filter :load_post, :protect

  def new 
    @comment = Comment.new 
    if params[:with_image] 
     render :action => "new_with_image"
    end  
  end

  def create 
    @comment = Comment.new(params[:comment]) 
    @comment.user = User.find(session[:user_id]) 
    @comment.post = @post 
    @comment.save
    @post.commented_on = Time.now
    @post.save

        if params[:image]
         image = params[:image]["file_data"]
         if image != ""
          @image = Image.create(:file_data => image, :owner_id => @comment.id, :owner_type => 'Comment', :filename => image.original_filename)
         end
        end

    respond_to do |format| 
      if @comment.duplicate? or true
        format.html { redirect_to "/posts/" + @post.id.to_s }
        format.js # create.rjs 
      else 
        format.html { redirect_to new_comment_url(@post.blog, @post) } 
        format.js { render :nothing => true } 
      end 
    end 
  end
  
  def destroy 
    @comment = Comment.find(params[:id]) 
    
    if @comment.authorized?(session[:user_id]) 
      @comment.destroy 
    else 
      redirect_to "/"
      return 
    end 
  
    respond_to do |format| 
      format.js # destroy.rjs 
    end
  end

  private 

  def load_post 
    @post = Post.find(params[:post_id]) 
  end 
end
