module MessagesHelper
  
  def link_to_message(user, message)
    string = link_to truncate(message.subject), user_message_path(user, message, :page => params[:page]), :class => 'ajax'
    string = "<strong>#{string}</strong>" unless message.read?
    string
  end

end
