class Admin::MassMessagesController < Admin::AdminController #:nodoc:
  layout nil

  def index
    @messages = User.myousica.sent_messages.find(:all)
    @count = User.myousica.sent_messages.count
  end

  def new
    @message = Message.new
    @user_count = User.count_activated
  end

  def show
    @message = Message.read(params[:id], User.myousica)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Message not found"
    redirect_to :action => 'index'
  end

  def create
    count = 0

    User.find_activated.each do |user|
      next if user == User.myousica

      @message = Message.new(params[:message])
      @message.sender = User.myousica
      @message.recipient = user
      if @message.save
        UserMailer.deliver_message_notification(@message)
        count += 1
      end
    end

    # -1 because no mail is sent to the 'myousica' user
    flash[:notice] = "Sent #{count} messages out of #{User.count_activated - 1} users" 
    redirect_to :action => 'index'
  end
end
