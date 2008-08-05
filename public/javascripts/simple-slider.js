var SimpleSlider = Class.create({
  initialize: function(element, options) {
    this.outer = $(element);
    if (!this.outer)
      return;

    var coords = Object.extend({
      x: 0,
      y: 300
    }, options);

    this.container = this.outer.down('div.slide-container');
    this.elements = this.container.down('div.slide-contents');

    this.b_slide_prev = this.slide.bind(this, coords);
    this.prev_trigger = this.outer.down('a.slide-prev');

    this.b_slide_next = this.slide.bind(this, {x: -coords.x, y: -coords.y});
    this.next_trigger = this.outer.down('a.slide-next');

    this.prev_trigger.observe('click', this.b_slide_prev);
    this.next_trigger.observe('click', this.b_slide_next);

    Event.observe(window, 'unload', this.destroy.bind(this));		
  },

  destroy: function() { 
    this.prev_trigger.stopObserving('click', this.b_slide_prev);
    this.next_trigger.stopObserving('click', this.b_slide_next);
    this.outer = null;
    this.container = null;
    this.elements = null;
    this.prev_trigger = null;
    this.next_trigger = null;
  },

  slide: function(coords, event) {
    event.stop();

    if (this.sliding)
      return;

    var top = parseInt(this.elements.style.top) || 0;
    var left = parseInt(this.elements.style.left) || 0;

    if ((coords.y > 0 && top >= 0) || (coords.x > 0 && left >= 0))
      return;

    if ((coords.y < 0 && -top > this.elements.getHeight() - this.container.getHeight()) ||
        (coords.x < 0 && -left > this.elements.getWidth() - this.container.getWidth()))
      return;

    this.sliding = true;
    new Effect.Move(this.elements, {
      x: coords.x,
      y: coords.y,
      mode: 'relative',
      transition: Effect.Transitions.sinoidal,
      duration: 0.3,
      afterFinish: function() { this.sliding = false }.bind(this)
    });
  }

});

