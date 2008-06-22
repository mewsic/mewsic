var Player = Class.create({

  initialize: function() {
    this.container = $('player-container');
    this.content = this.container.down('.content');
    this.open = false;
    this.links = new Array();
    this.initLinks();
    Ajax.Responders.register({
      onComplete: this.initLinks.bind(this)      
    });
  },
  
  initLinks: function() {
    $$('a.player').each(function(element) {
      if(!this.links.include(element)) {
        this.links.push(element);
        element.observe('click', this.handleClick.bindAsEventListener(this, element));
      }      
    }.bind(this));
  },
  
  handleClick: function(event, link) {
    event.stop();
    var url = link.getAttribute('href');    
    this.openContainer(url);
  },
  
  openContainer: function(url) {
    if(this.open) {
      this.clearContent();
      this.loadPage(url);
    } else {   
      this.open = true;
      Effect.BlindDown(this.container, {      
        afterFinish: function() {
          this.loadPage(url);
        }.bind(this)
      });
    }    
  },
  
  close: function() {    
    Effect.BlindUp(this.container);
    this.open = false;
    this.clearContent();
  },
  
  clearContent: function() {
    this.content.update('');
  },
  
  loadPage: function(url) {
    new Ajax.Updater(this.content, url, {
      method: 'get'
    });
  }
  
});

Player.init = function() {
  Player.instance = new Player();
}

var Pagination = Class.create({ 

  initialize: function() {
    this.options = Object.extend({
      container: 'container',
      selector: 'div.pagination a'
    }, arguments[0] || {});
    this.initLinks();
  },  

  initLinks: function() {
    if (!$(this.options.container))
      return;
    $(this.options.container).select(this.options.selector).invoke('observe', 'click', this.linkHandler.bind(this));
  },  

  linkHandler: function(event) {
    event.stop(); 
    new Ajax.Updater(this.options.container, event.element().getAttribute('href'), {
      method: 'get',
      onLoading: function(event){ if(this.options.spinner) $(this.options.spinner).show(); }.bind(this),
      onComplete: this.initLinks.bind(this)
    });
  }

});

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
  // $('search').down('input').focus();
  Player.init();
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

  new SearchBox('search');

  $$('.instrument').each(function(element) {
    new Tip(element, element.getAttribute('rel'));
  });
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
