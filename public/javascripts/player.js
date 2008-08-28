var Player = Class.create({

  initialize: function() {
    this.container = $('player-container');
    this.content = this.container.down('.content');
    this.open = false;
    this.buttons = new Array();
    this.initLinks();

    Ajax.Responders.register({
      onComplete: this.initLinks.bind(this)      
    });

    Event.observe(window, 'unload', this.destroy.bind(this));
  },

  destroy: function(event) {
    this.buttons.each(function(button) {
      button.image.stopObserving('click', button.callback);
      button.image = null;
      button.callback = null;
    });

    this.buttons = null;
    this.container = null;
    this.content = null;
  },
  
  initLinks: function(r) {
    // remove all the links no longer in the page
    this.buttons = this.buttons.reject(function(button) {
      if (!button.image.parentNode) {
        button.image.stopObserving('click', button.callback);
        return true;
      }
      return false;
    }.bind(this));

    // add any new links
    $A(document.getElementsByClassName('player')).each(function(image) {
      if (image._playable)
        return;

      var callback = this.handleClick.bindAsEventListener(this, image);
      image.observe('click', callback);
      image._playable = true;
      this.buttons.push({image: image, callback: callback});
    }.bind(this));

  },

  handleClick: function(event, image) {
    event.stop();
    this.openContainer(image.getAttribute('rel'));
  },
  
  openContainer: function(url) {
    if(this.open) {
      this.clearContent();
      this.loadPage(url);
    } else {   
      this.open = true;
      var effect = (Prototype.Browser.IE) ? Effect.Appear : Effect.BlindDown;
      new effect(this.container, {
        duration: 0.5,
        afterFinish: function() { this.loadPage(url); }.bind(this)
      });
    }    
  },
  
  close: function() {
    this.open = false;
    this.clearContent();
    var effect = (Prototype.Browser.IE) ? Effect.Fade : Effect.BlindUp;
    new effect(this.container, {duration: 0.5});
  },
  
  clearContent: function() {
    this.content.update('');
  },
  
  loadPage: function(url) {
    new Ajax.Updater(this.content, url, {
      method: 'get', evalScripts: true
    });
  }
  
});

document.observe('dom:loaded', function(event) {
  Player.instance = new Player();
});
