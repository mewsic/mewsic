var Rating = Class.create({
  initialize: function(options) {
    this.options = options;
    this.logged_in = $('current-user-id') ? true : false;
    this.elements = $A();
    this.starboxes = $A();

    var elements = $A(document.getElementsByClassName(this.options.className));
    elements.slice(0, options.limit).each(this.add.bind(this));

    if (this.logged_in) {
      this.authenticity_token = $('authenticity-token').value;
      this.b_onrate = this.onrate.bind(this);
      document.observe('starbox:rated', this.b_onrate);
    }

    Ajax.Responders.register({
      onComplete: this.responder.bind(this)
    });

    Event.observe(window, 'unload', this.destroy.bind(this));		
  },

  destroy: function() {
    document.stopObserving('starbox:rated', this.b_onrate);

    this.starboxes.each(function(starbox) {
      starbox.buttons.clear();
      starbox.buttons = null;

      starbox.inputs.average = null;
      starbox.inputs.max = null;
      starbox.inputs.rated = null;
      starbox.inputs.rerated = null;
      starbox.inputs.total = null;
      starbox.inputs = null;

      starbox.colorbar = null;
      starbox.container = null;
      starbox.element = null;
      starbox.hover = null;
      starbox.starbar = null;
      starbox.status = null;
      starbox.wrapper = null;
    });

    this.starboxes.clear();
    this.starboxes = null;

    this.elements.clear();
    this.elements = null;

  },

  onrate: function(event) {
    var rateable = event.memo.identity.split(/_/)[0];
    var id = event.memo.identity.split(/_/)[1];
    new Ajax.Request('/' + rateable + 's/' + id + '/rate/', {
      method: 'PUT',
      parameters: { authenticity_token: this.authenticity_token,
                    rate: event.memo.rated }
    });
  },

  add: function(element) {
    var className = element.className.sub(/\s*rating\s*/, '');
    var rel = element.getAttribute('rel').split(/ /);
    var rating = parseFloat(rel[0]) || 0;
    var count = parseFloat(rel[1]) || 0;

    var image = 'myousica_small.png';
    var locked = !this.logged_in;
    var indicator = false;

    if (element.hasClassName('grey-star')) {
      image = 'grey_myousica_small.png';
    } else if (element.up('.user-resume') || element.up('.song-resume') || element.up('.answer-show')) {
      image = 'myousica_big.png';
    } else if (element.up('.answer-small') || element.up('.azzurro-box')) {
      image = 'myousica_f3f8fa.png';
    } else if (element.up('.grey-box')) {
      image = 'myousica_f9f9f9.png';
    }

    if (element.hasClassName('locked')) {
      locked = true;
      indicator = '<strong>#{average}</strong> rating from <strong>#{total}</strong> votes';
    }

    this.elements.push(element);
    this.starboxes.push(new Starbox(element, rating, {
      total: count,
      buttons: 5,
      max: 5,
      className: className,
      identity: element.id,
      indicator: indicator,
      locked: locked,
      overlay: image
    }));
  },

  responder: function(r) {
    if (!r.container || !r.container.success)
      return;

    var container = $(r.container.success);
    if (container) {
      container.select('.' + this.options.className).each(this.add.bind(this));
    }
  }
});

document.observe('dom:loaded', function(event) {
  Rating.instance = new Rating({className: 'rating', limit: 30});
});
