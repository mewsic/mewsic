var Ideas = Class.create({
  container: 'ideas-by-instruments',
  instruments_container: 'all-instruments',
  spinner: 'tab-spinner',

  initialize: function() {
    this.container = $(this.container);
    this.instruments_container = $(this.instruments_container);
    this.spinner = $(this.spinner);

    this.setup_all_instruments();
    this.setup_table_instruments();

    this.reset_link = $('ideas-tab').down('a');
    this.reset_link._click = this.reset.bind(this);
    this.reset_link.observe('click', this.reset_link._click);

    Ajax.Responders.register({
      onComplete: this.responder.bind(this)
    });

    Event.observe(window, 'unload', this.destroy.bind(this));
  },

  destroy: function() {
    // XXX
  },

  responder: function() {
    this.table_instruments.clear();
    this.setup_table_instruments();
  },

  setup_all_instruments: function() {
    this.all_instruments = this.instruments_container.select('a.browse');
    this.all_instruments.each(function(link) {
      link._image = link.down('img');
      this.setupLink(link);
    }.bind(this));
  },

  setup_table_instruments: function() {
    this.table_instruments = this.container.select('a.browse');
    this.table_instruments.each(function(link) {
      link._image = $(link.getAttribute('rel'));
      link._link = link._image.up();
      this.setupLink(link);
    }.bind(this));
  },

  setupLink: function(link) {
    link.stopObserving('click', link._click);
    link._click = this.browse.bind(this, link);
    link.observe('click', link._click);

    link._image.addClassName('faded');

    if (!link._mouseover)
      link._mouseover = this.unfade.bind(this, link._image);
    link.observe('mouseover', link._mouseover);

    if (!link._mouseout)
      link._mouseout = this.fade.bind(this, link._image);
    link.observe('mouseout', link._mouseout);
  },

  setCurrentLink: function(link) {
    if (link._link) {
      link.stopObserving('mouseout', link._mouseout);
      link = link._link; // yuck :P
    }

    if (link._mouseover)
      link.stopObserving('mouseover', link._mouseover);

    if (link._mouseout)
      link.stopObserving('mouseout', link._mouseout);

    link.stopObserving('click', link._click);
    link._click = this.scroll.bind(this);
    link.observe('click', link._click);

    link._image.removeClassName('faded');

    this.current = link;
  },

  resetCurrentLink: function() {
    if (!this.current) {
      return;
    }
    this.setupLink(this.current);
    this.current = null;
  },

  fade: function(image) {
    image.addClassName('faded');
  },

  unfade: function(image) {
    image.removeClassName('faded');
  },

  stopEvent: function(event) {
    event.stop();
  },

  scroll: function(event) {
    if (event)
      event.stop();

    new Effect.ScrollTo(this.container, {duration: 0.5, offset: -40});
  },

  fix_prototip: function() { 
    this.instruments_container.select('img.instrument').
      concat(this.container.select('img.instrument')).each(function(i) {
        i.prototip.hide();
      });
  },

  browse: function(link, event) {
    event.stop();

    this.scroll();

    this.resetCurrentLink();
    this.setCurrentLink(link);

    new Ajax.Updater(this.container, link.href, {
      method: 'GET',
      onLoading: function() {
        this.fix_prototip();
        this.spinner.show();
        this.container.setOpacity(0.2);
      }.bind(this),

      onComplete: function() {
        this.container.down('h2').highlight({duration: 2.0});
        this.container.setOpacity(1.0);
        this.spinner.hide(); 
      }.bind(this)
    });
  },

  reset: function(event) {
    event.stop();

    this.resetCurrentLink();

    new Ajax.Updater(this.container, this.reset_link.href, {
      method: 'GET',
      onLoading: function() {
        this.fix_prototip();
        this.spinner.show();
        this.container.setOpacity(0.2);
      }.bind(this),

      onComplete: function() {
        this.container.setOpacity(1.0);
        this.spinner.hide(); 
      }.bind(this)
    });
  }

});

document.observe('dom:loaded', function() {
  $w('newest coolest').each(function(name) {
    if (!$(name + '-ideas'))
      return;

    new Pagination({
      container: name + '-ideas',
      spinner: name + '-spinner',
      selector: 'a.navigation',
      dynamic_spinner: true,
      onComplete: function() {
        new Effect.ScrollTo(name + '-ideas', {duration: 0.7});
      }
    });
  });

  Ideas.instance = new Ideas();
});
