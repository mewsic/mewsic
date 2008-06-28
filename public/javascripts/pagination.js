var Pagination = Class.create({ 

  initialize: function() {
    this.options = Object.extend({
      container: 'container',
      selector: 'div.pagination a'
    }, arguments[0] || {});

    if (this.options.dynamic_spinner) {
      this.options.loading = new Loading({
        spinner: this.options.spinner, 
        container: this.options.container
      });
    }

    this.authenticity_token = $('authenticity-token').value;
    this.b_linkHandler = this.linkHandler.bindAsEventListener(this);
    this.initLinks();
  },

  initLinks: function() {
    if (!$(this.options.container))
      return;

    this.links = $(this.options.container).select(this.options.selector);
    this.links.invoke('observe', 'click', this.b_linkHandler);
  },

  linkHandler: function(event) {
    event.stop(); 

    var element = event.element();
    if (element.tagName != 'A') {
      element = element.up('a');
    }

    new Ajax.Updater(this.options.container, element.getAttribute('href'), {
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
    }
    this.links.invoke('stopObserving', 'click', this.b_linkHandler);
  },

  complete: function() {
    if (this.options.loading) {
      this.options.loading.hide();
    } else if (this.options.spinner) {
      $(this.options.spinner).hide();
    }

    if (this.options.update_mlab && typeof(MlabSlider) != 'undefined') {
      var mlabSlider = MlabSlider.getInstance();
      if (mlabSlider) {
        mlabSlider.initTrackButtons(true);
      }
    }

    this.initLinks();
  }

});
