var Message = {
  
  template: '<div class="#{type}">#{message}<div class="close"/></div>',
  
  show: function(message, type, close_previous) {
    if(close_previous) Message.closeAll();
    var tpl = new Template(Message.template); 
    var content = tpl.evaluate({message: message, type: type});
    $('messages').insert(content);
    Message.initCloseLinks();
  },
  
  initCloseLinks: function() {
    var e = $('messages');
    if(e) { 
      e.select('div.close').invoke('observe', 'click', Message.handleClose);
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
    event.element().up().fade({ duration: 0.3 });
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
  },
  
  init: function() {
    Message.initCloseLinks();
    if(Message.readInboxMessageCookie()) {
      var inbox_message = $('messages').down('.inbox'); 
      if(inbox_message) inbox_message.hide();
    }    
  }
  
}; 

// When object is available, do function fn.
function when(obj, fn) {
  if (Object.isString(obj)) obj = /^[\w-]+$/.test(obj) ? $(obj) : $(document.body).down(obj);
  if (Object.isArray(obj) && !obj.length) return;
  if (obj) fn(obj);
}

var SearchBox = Class.create({
  initialize: function(element) {
    element = $(element);
    if (!element)
      return;

    this.form = element.down('form');
    this.search_string = this.form.down('#q');
    this.submit = this.form.down('.submit-button');

    this.submit.observe('click', this.onSubmit.bind(this));
    this.form.observe('submit', this.onSubmit.bind(this));

    this.collapsed_box = element.down('.collapsed-box');
    this.advanced_box = element.down('.advanced-box');
    this.collapsed_box.down('.trigger').observe('click', this.showAdvancedBox.bind(this));
    this.advanced_box.down('.trigger').observe('click', this.showCollapsedBox.bind(this));

    this.links = this.advanced_box.select('a');
    this.boxes = this.advanced_box.select('input');
    $R(0, this.links.size(), true).each(function(i) {
      this.links[i].observe('click', function(box, event) {
        event.stop();
        box.checked = !box.checked
      }.bind(this, this.boxes[i]))
    }.bind(this));
  },
    
  showAdvancedBox: function(event) {
    event.stop();
    new Effect.Fade(this.collapsed_box, {duration: 0.3});
    new Effect.Appear(this.advanced_box, {duration: 0.3, queue: 'end'});
  },

  showCollapsedBox: function(event) {
    event.stop();
    new Effect.Fade(this.advanced_box, {duration: 0.3});
    new Effect.Appear(this.collapsed_box, {duration: 0.3, queue: 'end'});
  },

  onSubmit: function(event) {
    event.stop();

    if (this.search_string.value.blank()) {
      alert('Please enter a search string');
      return;
    }

    this.form.submit();
  }
});  

        
document.observe('dom:loaded', function(event) {
  //$('search').down('input').focus();
  //$('logo').focus();
  
  SearchBox.instance = new SearchBox('search');
  Message.init();
});

var Popup = {
  open: function(url) {
    var options = Object.extend({
      name: 'popup',
      width: 500,
      height: 500,
      resizable: 'yes',
      scrollbars: 'yes'
    }, arguments[1] || {});
    var left = window.innerWidth / 2 - options.width / 2;
    var top  = window.innerHeight / 2 - options.height / 2;
    window.open(url, options.name, 'left=' + left + ',top=' + top + ',width=' + options.width + ',height=' + options.height + ',resizable=' + options.resizable + ',scrollbars=' + options.scrollbars);    
  }
};

function pop(url) {
  var popup = window.open(url,'popup', 'height=100, width=300');
  if (window.focus) {
    popup.focus()
  }
  return false;
}

function reload() {
  //var anchor = /#/.test(window.location.href);
  window.location.href = window.location.href.sub(/[#?].*/, '');
  //if (anchor && Prototype.Browser.WebKit)
  //  window.location.href = window.location.href;
}
