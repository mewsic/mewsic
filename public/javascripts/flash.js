var Message = {
  
  template: new Template('<div class="#{type}"><p class="float-left">#{message}</p><div class="close float-right"><img src="/images/button_flash_close.png"></div></div>'),
  
  init: function() {
    Message.initCloseLinks();
    if(Message.readInboxMessageCookie()) {
      var inbox_message = $('messages').down('.inbox'); 
      if(inbox_message) inbox_message.hide();
    }
    Event.observe(window, 'unload', Message.releaseCloseLinks);
  },
  
  show: function(message, type, close_previous) {
    if(close_previous) Message.closeAll();
    var content = Message.template.evaluate({message: message, type: type});
    $('messages').insert(content);
    Message.initCloseLinks();
  },
  
  initCloseLinks: function() {
    var e = $('messages');
    if(e) { 
      e.select('div.close').invoke('observe', 'click', Message.handleClose);
    }
  },

  releaseCloseLinks: function() {
    var e = $('messages');
    if (e) {
      e.select('div.close').invoke('stopObserving', 'click', Message.handleClose);
    }
  },
  
  closeAll: function() {
    var e = $('messages');
    if(e) {
      e.select('div').invoke('hide');
    }
  },
  
  handleClose: function(event) {
    if(event.element().up().hasClassName('inbox')) {
      Message.saveInboxMessageCookie();
    }
    event.element().up().up().fade({ duration: 0.3 });
  },
  
  readInboxMessageCookie: function() {
    var matches = document.cookie.match(/inbox_message_read=(.+?)/);
    var value = matches ? matches[1] : 0;
    return value;
  },
  
  saveInboxMessageCookie: function() {
    document.cookie = "inbox_message_read=1; path=/";
  },
  
  error: function(message, close_previous) {
    Message.show(message, 'error', close_previous);
  },
  
  notice: function(message, close_previous) {
    Message.show(message, 'notice', close_previous);
  }
  
}; 

document.observe('dom:loaded', function(event) {
  Message.init();
});
