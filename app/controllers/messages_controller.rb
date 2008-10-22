# Myousica Messages Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
#
# == Description
#
# This RESTful controller implements the user's message centre. Messages are shown into a
# <tt>DIV</tt> and contents are loaded only via XHR. There is a received message +index+,
# a +sent+ one and a +received+ one. Messages are shown via the +show+ action and created
# via the +new+ and +create+ ones. Deletion is handled by +destroy+.
#
# Before accessing this controller, a valid user id must be passed (+find_user+ filter),
# the user must be logged in (+login_required+) and must be the same user as the one passed
# (+check_user_identity+ filter).
#
# See <tt>public/javascripts/user/mail.js</tt> for details on the client.
#
class MessagesController < ApplicationController
  
  layout false
  
  before_filter :redirect_to_root_unless_xhr
  before_filter :find_user
  before_filter :login_required
  before_filter :check_user_identity  
  before_filter :fix_page_number, :only => :index
  
  # ==== GET /users/:user_id/messages
  #
  # Returns the User#received_messages index, paginated with 10 elements per page.
  # If the page number passed is greater than the page count, the last page is rendered.
  #
  def index
    @messages = @user.received_messages.paginate(:page => @page, :per_page => 10)

    if @messages.page_count > 1 && params[:page].to_i > @messages.page_count
      redirect_to(:action => 'index', :page =>  @messages.page_count) and return
    end
  end

  # ==== GET /users/:user_id/messages/sent
  #
  # Renders the User#sent_messages index, using the <tt>index.html.erb</tt> template.
  # Paginated with 10 messages per page.
  #
  def sent       
    @messages = @user.sent_messages.paginate(:page => params[:page], :per_page => 10)
    render :action => 'index'
  end
  
  # ==== GET /users/:user_id/messages/unread
  #
  # Renders the User#received_messages index, using the <tt>index.html.erb</tt>template.
  # Paginated with 10 messages per page.
  #
  def unread       
    @messages = @user.received_messages.paginate(:conditions => ["read_at IS NULL"], :page => params[:page], :per_page => 10)
    render :action => 'index'                                   
  end

  # ==== GET /users/:user_id/messages/:id
  #
  # Shows a message, reading it using the Message#read method and showing it using the 
  # <tt>show.html.erb</tt> partial. If no message with the passed id is found, the <tt>
  # not_found</tt> partial is rendered.
  #
  def show
    @message = Message.read(params[:id], @user)
  rescue ActiveRecord::RecordNotFound
    render :partial => 'not_found'
  end

  # ==== GET /users/:user_id/messages/new
  #
  # Shows the message composition form, filling recipient, subject and body if this is
  # a reply to another message. In this case, the replying message id is passed via
  # <tt>params[:reply]</tt>, the subject is prepended with a "RE: " and every line of
  # the original message body is prepended with ">". Classical e-mail quoting. :-).
  #
  # If the replying message is not found, a blank message composition form is shown.
  #
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

  # ==== POST /users/:user_id/messages
  #
  # Creates a new message. Multiple recipients may be specified, separating them
  # with a comma. Results are rendered by the <tt>create.js.erb</tt> view, 'cause
  # this action only supports JS output.
  #
  # If an user specifies an invalid recipient, it is saved into the @bad_recipients ivar
  # and an appropriate error message is shown (see the <tt>create.js.erb</tt> template).
  # Good recipients are saved into the @good_recipients ivar, and shown in a notice message.
  #
  def create
    @bad_recipients = []
    @good_recipients = []
    params[:message][:to].split(',').map!(&:strip).uniq.each do |login|
      @message = Message.new(params[:message])
      @message.sender = @user
      @message.recipient = User.find_by_login(login)
      if @message.save
        UserMailer.deliver_message_notification(@message)
        @good_recipients << login
      else
        @bad_recipients << login
      end
    end

    respond_to do |format|
      format.js
    end
  end
  
  # ==== DELETE /users/:user_id/messages/:id
  #
  # Destroys a message by marking it as deleted (see the +mark_deleted+ method).
  #
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

  # Filter that finds an user by login and redirects to '/' if not found.
  #
  def find_user
    @user = User.find_from_param(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to '/'
  end
  
  # Filter that sets the page number to 1 if it is < 1
  #
  def fix_page_number
    @page = params[:page].to_i < 1 ? 1 : params[:page]
  end
  
  # Filter that checks that the passed user id is the same as the current logged in user id.
  #
  def check_user_identity
    render :text => 'You cannot access this mailbox.', :status => :forbidden unless (current_user == @user) || current_user.is_admin?
  end
  
end
