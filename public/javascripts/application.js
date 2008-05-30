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

var LoginEase = {
  activate: function(e) {
    var element = Event.element(e);
    var defvalue = $A(arguments)[1];
    if (element.value == defvalue)
      element.value = '';
  },
  deactivate: function(e) {
    var element = Event.element(e);
    var defvalue = $A(arguments)[1];
    if (element.value == '')
      element.value = defvalue;
  }
}

var SearchBoxBehaviour = Class.create({
  initialize: function(element) {
    element = $(element);
    if (!element)
      return;

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
  }
});

document.observe('dom:loaded', function(event) {
	// Login Behavior
	if ( $('log-in') != null ) {
      Event.observe( $('login'), 'focus', LoginEase.activate.bindAsEventListener(this, 'username') );
      Event.observe( $('password'), 'focus', LoginEase.activate.bindAsEventListener(this, 'password') );
      Event.observe( $('login'), 'blur', LoginEase.deactivate.bindAsEventListener(this, 'username') );
      Event.observe( $('password'), 'blur', LoginEase.deactivate.bindAsEventListener(this, 'password') );
	}

    // $('search').down('input').focus();
    $('logo').focus();

	if ( $('log-in-errors') != null && $('log-in-errors').visible() ) {
		$('log-in').down('input', 2).clear().focus();
	}
	
	if ( $('most-friends-scroller') != null ) {
		// new PictureSlider('most-friends-scroller',  { size: 225 });
	} 
	
	if ( $('most-mbands-scroller') != null ) {
		// new PictureSlider('most-mbands-scroller',  { size: 225 });
	}
	

	if ($('mlab-scroller') != null ) {
	  var mlab_slider = new MlabSlider('mlab-scroller',  {
      axis: 'vertical',
      windowSize: 5,
      size: 300,
      toggleTriggers: true
    });    
	}
	
	if($('current-user-id')) {	  
	  var authenticity_token = $('authenticity-token').value;
  	new Rating('song_rating', {
      hideLabelOnMouseOut: true,
      ajaxUrl: '/songs/#{id}/rate/',
      ajaxMethod: 'PUT',
      ajaxParameters: 'authenticity_token=' + encodeURIComponent(authenticity_token) + '&rate=#{rate}'
  	});
  	new Rating('track_rating', {
  	  hideLabelOnMouseOut: true,
      ajaxUrl: '/tracks/#{id}/rate/',
      ajaxMethod: 'PUT',
      ajaxParameters: 'authenticity_token=' + encodeURIComponent(authenticity_token) + '&rate=#{rate}'
  	});
  	new Rating('answer_rating', {
  	  hideLabelOnMouseOut: true,
      ajaxUrl: '/answers/#{id}/rate/',
      ajaxMethod: 'PUT',
      ajaxParameters: 'authenticity_token=' + encodeURIComponent(authenticity_token) + '&rate=#{rate}'
  	});
  	new Rating('reply_rating', {
  	  hideLabelOnMouseOut: true,
      ajaxUrl: '/replies/#{id}/rate/',
      ajaxMethod: 'PUT',
      ajaxParameters: 'authenticity_token=' + encodeURIComponent(authenticity_token) + '&rate=#{rate}'
  	});
  	new Rating('user_rating', {
  	  hideLabelOnMouseOut: true,
      ajaxUrl: '/users/#{id}/rate/',
      ajaxMethod: 'PUT',
      ajaxParameters: 'authenticity_token=' + encodeURIComponent(authenticity_token) + '&rate=#{rate}'
  	});
  	new Rating('mband_rating', {
      hideLabelOnMouseOut: true,
      ajaxUrl: '/mbands/#{id}/rate/',
      ajaxMethod: 'PUT',
      ajaxParameters: 'authenticity_token=' + encodeURIComponent(authenticity_token) + '&rate=#{rate}'
  	});
	}	
		 
  Message.init();

  new SearchBoxBehaviour('search');
 
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
	newwindow = window.open(url,'popup', 'height=100, width=300');
	if (window.focus) {newwindow.focus()}
	return false;
}
