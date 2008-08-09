var Player = Class.create({

  initialize: function() {
    this.container = $('player-container');
    this.content = this.container.down('.content');
    this.open = false;
    this.buttons = new Hash();
    this.initLinks();

    Ajax.Responders.register({
      onComplete: this.initLinks.bind(this)      
    });

    Event.observe(window, 'unload', this.destroy.bind(this));
  },

  destroy: function(event) {
    this.buttons.each(function(row) {
      row = row[1]
      row.image.stopObserving('click', row.callback);
      row.image = null;
      row.callback = null;
    });

    this.buttons = null;
    this.container = null;
    this.content = null;
  },
  
  initLinks: function(r) {
    // remove all the links no longer in the page
    this.buttons.each(function(row) {
      var address  = row[0];
      var image    = row[1].image;
      var callback = row[1].callback;

      if (!image.parentNode) {
        image.stopObserving('click', callback);
        this.buttons.unset(address);
      }

    }.bind(this));

    // add any new links
    $A(document.getElementsByClassName('player')).each(function(image) {
      if (this.buttons.get(image.getAttribute('rel'))) {
        return;
      }

      var callback = this.handleClick.bindAsEventListener(this, image);
      image.observe('click', callback);
      this.buttons.set(image.getAttribute('rel'), {image:image, callback:callback});

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
      method: 'get', evalScripts: true
    });
  }
  
});

document.observe('dom:loaded', function(event) {
  Player.instance = new Player();
});
