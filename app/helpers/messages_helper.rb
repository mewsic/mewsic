module MessagesHelper
  
  def link_to_message_by_body(user, message)
    string = link_to truncate(message.subject, :length => 50), user_message_path(user, message, :page => params[:page]), :class => 'ajax'
    string = "<strong>#{string}</strong>" if user == message.recipient && !message.read?
    string
  end
  
  def link_to_message_by_user(user, message)
    _user = message.sender == user ? message.recipient : message.sender
    text = _user ? _user.login : 'Unknown'
    string = link_to truncate(text), user_message_path(user, message, :page => params[:page]), :class => 'ajax'
    string = "<strong>#{string}</strong>" if user == message.recipient && !message.read?
    string
  end
  
  def sanitize_message(message)
    white_list message.body.gsub("\n", "<br />")    
  end

  def update_messages_count_javascript_for(user)
    %(MailBox.instance.updateUnreadCount(#{user.unread_message_count});
      MailBox.instance.updateReceivedCount(#{user.received_messages.count});)
  end

  def current_page_number
		%[<div style="display:none" class="pagination"><span class="current">#{@page}</span></div>]
  end
end
