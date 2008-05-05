class MessagesController < ApplicationController 

before_filter :protect, :find_user


def find_user
 @user = User.find(session[:user_id])
end


def inbox
    @user.update_attribute("unread_message",false)
 
    @messages = Message.paginate(:all, :conditions => ["to_user_id = ? and deleted = ?", session[:user_id], false],
                           :page => params[:page], :per_page => 20, :order => "messages.created_on desc", :include => [ :user ])

end


def send_message # send is reserved word
    case request.method
      when :post
        @to_user = User.find_by_login(params[:message][:to])
        if @to_user
          Message.create(:body => params[:message][:body], :user_id => @user.id, :to_user_id => @to_user.id)
          @to_user.update_attribute("unread_message",true)
          flash[:notice] = 'Message Sent.'
          redirect_to :action => "inbox" 
        else
          flash[:notice] = 'Could Not Find that user :('
        end
      when :get
      end
end

def destroy

case request.method
 when :post
    @message = Message.find(params[:id])
    if @message.to_user_id == session[:user_id]
      @message.update_attribute("deleted", true)
      flash[:notice] = 'Message Erased.'
    else
     flash[:notice] = 'Hacking?'
    end
 else
  flash[:notice] = 'What are you doing?'
 end

redirect_to :action => "inbox" 

end


end
