var Player = Class.create({

  initialize: function() {
    this.container = $('player-container');
    this.content = this.container.down('.content');
    this.open = false;
    this.links = new Hash();
    this.initLinks();
    Ajax.Responders.register({
      onComplete: this.initLinks.bind(this)      
    });
  },
  
  initLinks: function(r) {
    // remove all the links no longer in the page
    this.links.each(function(row) {
      var href     = row[0];
      var link     = row[1].link;
      var callback = row[1].callback;

      if (!link.parentNode) {
        link.stopObserving('click', callback);
        this.links.unset(href);
      }

    }.bind(this));

    // add any new links
    /*
    $A(document.getElementsByClassName('player')).each(function(link) {
      if (this.links.get(link.href)) {
        return;
      }
      */

    var elements;

    if (r)
      elements = $(r.container.success).select('.player')
    else
      elements = $A(document.getElementsByClassName('player'))

    elements.each(function(link) {
      var callback = this.handleClick.bindAsEventListener(this, link);
      link.observe('click', callback);
      this.links.set(link.href, {link: link, callback: callback});

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
      method: 'get', evalScripts: true
    });
  }
  
});

document.observe('dom:loaded', function(event) {
  Player.instance = new Player();
});
