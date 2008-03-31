module MessagesHelper
  
  def link_to_message_by_body(user, message)
    string = link_to truncate(message.subject), user_message_path(user, message, :page => params[:page]), :class => 'ajax'
    string = "<strong>#{string}</strong>" unless message.read?
    string
  end
  
  def link_to_message_by_user(user, message)        
    _user = message.sender == user ? message.recipient : message.sender
    text = _user ? _user.login : 'Unknown'
    string = link_to truncate(text), user_message_path(user, message, :page => params[:page]), :class => 'ajax'
    string = "<strong>#{string}</strong>" unless message.read?
    string
  end

end
