var Pagination = Class.create({ 

  initialize: function() {        
    this.options = Object.extend({
      container: 'container',
      selector: 'div.pagination a'
    }, arguments[0] || {});

    if (!$(this.options.container))
      return;

    if (!this.options.update)
      this.options.update = this.options.container;

    if (this.options.dynamic_spinner) {
      this.options.loading = new Loading({
        spinner: this.options.spinner, 
        container: this.options.container
      });
    }
    this.authenticity_token = $('authenticity-token').value;
    this.initLinks();
    Event.observe(window, 'unload', this.releaseLinks.bind(this));
  },

  initLinks: function() {
    this.links = $(this.options.container).select(this.options.selector);
    this.links.each(function(link) {
      link._handler = this.linkHandler.bind(this, link);
      link.observe('click', link._handler);
    }.bind(this));
  },
  
  releaseLinks: function() {
    this.links.each(function(link) {
      link.stopObserving('click', link._handler);
      link._handler = null;
    }); 
    this.links.clear();
    this.links = null;
  },

  linkHandler: function(element, event) {
    event.stop(); 
    new Ajax.Updater(this.options.update, element.getAttribute('href'), {
      method: 'GET',
      parameters: { authenticity_token: this.authenticity_token },
      onLoading: this.loading.bind(this),
      onComplete: this.complete.bind(this)
    });
  },

  loading: function() {
    if (this.options.loading) {
      this.options.loading.show();
    } else if (this.options.spinner) {
      $(this.options.spinner).show();
    } else if (this.options.spinners) {
      this.options.spinners.each(function(id) {
        $(id).show();
      })
    }
    this.releaseLinks();
  },

  complete: function() {
    if (this.options.loading) {
      this.options.loading.hide();
    } else if (this.options.spinner) {
      $(this.options.spinner).hide();
    }    

    if (this.options.onComplete) {
      this.options.onComplete();
    }

    this.initLinks();
  }

});
