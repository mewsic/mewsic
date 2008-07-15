var Refresher = Class.create({
  initialize: function(element, options) {
    element = $(element);
    if (!element)
      return;

    this.container = element.down('.refresh-container');
    this.trigger = element.down('a.trigger');
    this.image = this.trigger.down('img');

    this.options = Object.extend({
      image: '/images/refresh.png',
      spinner: '/images/spinner.gif'
    }, options);

    this.b_refresh = this.refresh.bind(this);

    this.trigger.observe('click', this.b_refresh);
    Event.observe( window, 'unload', this.destroy.bind(this));
  },
  
  destroy: function() {
    this.trigger.stopObserving('click', this.b_refresh);
    this.container = null;
    this.trigger = null;
    this.image = null;
  },

  refresh: function(event) {
    event.stop();

    if (this.refreshing)
      return;
    this.refreshing = true;

    new Ajax.Updater(this.container, this.trigger.href, {
      method: 'get',
      onLoading: this.loading.bind(this),
      onComplete: this.complete.bind(this)
    });
  },

  loading: function() {
    this.image.src = this.options.spinner;
    this.container.fade({duration: 0.6, queue: 'end'});
  },

  complete: function() {
    this.image.src = this.options.image;
    this.container.appear({duration: 0.6, queue: 'end'});
    if (this.options.onComplete)
      this.options.onComplete();

    this.refreshing = false;
  },

  __dummy__: function() {}
});
