class MessagesController < ApplicationController
  
  layout false
  
  before_filter :find_user
  before_filter :login_required
  before_filter :check_user_identity  
  before_filter :fix_page_number, :only => :index
  
  def index
    @messages = @user.received_messages.paginate(:page => @page, :per_page => 10)
    # redirigo all'ultima pagina utile
    if @messages.page_count > 1 && params[:page].to_i > @messages.page_count
      redirect_to(:action => 'index', :page =>  @messages.page_count) and return
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @messages }      
    end
  end

  def sent       
    @messages = @user.sent_messages.paginate(:page => params[:page], :per_page => 10)
    render :action => 'index'
  end
  
  def unread       
    @messages = @user.received_messages.paginate(:conditions => ["read_at IS NULL"], :page => params[:page], :per_page => 10)
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
    @message = Message.new(params[:message])
    if params[:reply] && original_message = Message.read(params[:reply], @user)
      @message.to = original_message.sender.login
      @message.subject = "RE: #{original_message.subject}"
      @message.body = original_message.body.collect{|line| ">#{line}"}.unshift("\n\n\n")
    elsif params[:to]
      @message.to = params[:to]
    end
  rescue ActiveRecord::RecordNotFound
  end

  def create
    @bad_recipients = []
    params[:message][:to].split(',').each do |login|
      login.strip!
      @message = Message.new(params[:message])
      @message.sender = @user
      @message.recipient = User.find_by_login(login)
      unless @message.save
        @bad_recipients << login
      end
    end    
        
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @message = Message.read(params[:id], @user)
    @message.mark_deleted(@user)
    respond_to do |format|
      format.html do        
        redirect_to :action => (@message.sender == @user ? 'sent' : 'index'), :page => params[:page]
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
  
  def fix_page_number
    @page = params[:page].to_i < 1 ? 1 : params[:page]
  end
  
  def check_user_identity
    redirect_to('/') and return unless current_user == @user
  end
  
end
