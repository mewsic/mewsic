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
    event.element().up().fade({ duration: 0.3 });
  },
  
  error: function(message, close_previous) {
    Message.show(message, 'error', close_previous);
  },
  
  notice: function(message, close_previous) {
    Message.show(message, 'notice', close_previous);
  },
  
  init: function() {
    Message.initCloseLinks();    
  }
  
};

// When object is available, do function fn.
function when(obj, fn) {
  if (Object.isString(obj)) obj = /^[\w-]+$/.test(obj) ? $(obj) : $(document.body).down(obj);
  if (Object.isArray(obj) && !obj.length) return;
  if (obj) fn(obj);
}

document.observe('dom:loaded', function(event) {
	// Login Behavior
	if ( $('log-in') != null ) {
		$('log-in').down('input', 1).focus();
	} else {
		$('search').down('input').focus();
	}

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
	newwindow = window.open(url,'popup', 'height=100, width=300');
	if (window.focus) {newwindow.focus()}
	return false;
}