class CommentsController < ApplicationController 
  
  def new 
    @comment = Comment.new 
  
    respond_to do |format|
      format.html # new.rhtml
      format.js # new.rjs 
    end 
  end
  
  def create 
    @comment = Comment.new(params[:comment]) 
    @comment.user = User.find(session[:user_id]) 
    @comment.post = @post 

    respond_to do |format| 
      if @comment.duplicate? or @post.comments << @comment
        format.html { redirect_to profile_for(@post.blog.user) }
        format.js # create.rjs 
      else 
        format.html { redirect_to new_comment_url(@post.blog, @post) } 
        format.js { render :nothing => true } 
      end 
    end 
  end
  
  def destroy 
    @comment = Comment.find(params[:id]) 
    user = User.find(session[:user_id]) 
    
    if @comment.authorized?(user) 
      @comment.destroy 
    else 
      redirect_to hub_url 
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
