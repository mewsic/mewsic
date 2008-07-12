var Refresher = Class.create({
  initialize: function(element, options) {
    this.element = $(element);
    this.options = options || {};
    this.trigger = this.element.up().down('a.trigger');
    this.image = this.trigger.down('img');
    this.b_refresh = this.refresh.bind(this);

    this.trigger.observe('click', this.b_refresh);
  },

  refresh: function(event) {
    event.stop();

    if (this.refreshing)
      return;
    this.refreshing = true;

    new Ajax.Updater(this.element, this.trigger.href, {
      method: 'get',
      onLoading: this.loading.bind(this),
      onComplete: this.complete.bind(this)
    });
  },

  loading: function() {
    this.image.src = '/images/spinner.gif';
    this.element.fade({duration: 0.6, queue: 'end'});
  },

  complete: function() {
    this.image.src = '/images/refresh.png';
    this.element.appear({duration: 0.6, queue: 'end'});
    if (this.options.onComplete)
      this.options.onComplete();

    this.refreshing = false;
  },

  __dummy__: function() {}
});
