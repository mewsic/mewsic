class MessagesController < ApplicationController
  
  layout false
  
  before_filter :find_user
  
  def index
    @messages = @user.received_messages.paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html
      format.xml { render :xml => @messages }      
    end
  end

  def sent
    @messages = @user.sent_messages.paginate(:page => params[:page], :per_page => 10)
    render :action => 'index'
  end

  def show
    @message = Message.read(params[:id], @user)
    respond_to do |format|
      format.html
      format.xml { render :xml => @message }      
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { render :partial => 'not_found' }
      format.xml { head :status => 404 }      
    end
  end

  def new
  end

  def create
  end
  
  def destroy
    @message = Message.read(params[:id], @user)
    @message.mark_deleted(@user)
    respond_to do |format|
      format.js do
        @messages = @user.sent_messages.paginate(:page => params[:page], :per_page => 10)
      end
    end
  end
    
private
  
  def find_user
    @user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to '/' }
      format.xml  { head :status => 404 }  
    end
  end
  
end
