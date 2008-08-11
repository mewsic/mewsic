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

    this.b_is_prev_slideable = this.slideable.bind(this, coords);
    this.b_is_next_slideable = this.slideable.bind(this, {x: -coords.x, y: -coords.y});

    this.b_afterSlide = this.afterSlide.bind(this);

    this.b_slide_prev = this.slide.bind(this, coords);
    this.b_slide_next = this.slide.bind(this, {x: -coords.x, y: -coords.y});

    this.prev_trigger = this.outer.down('a.slide-prev');
    this.next_trigger = this.outer.down('a.slide-next');

    this.prev_trigger.observe('click', this.b_slide_prev);
    this.next_trigger.observe('click', this.b_slide_next);

    this.updateTriggers();

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

  updateTriggers: function() {
    if (!this.b_is_prev_slideable.call()) {
      this.prev_trigger.setOpacity(0.2);
      this.prev_trigger.style.cursor = 'default';
    } else {
      this.prev_trigger.setOpacity(1.0);
      this.prev_trigger.style.cursor = 'pointer';
    }

    if (!this.b_is_next_slideable.call()) {
      this.next_trigger.setOpacity(0.2);
      this.next_trigger.style.cursor = 'default';
    } else {
      this.next_trigger.setOpacity(1.0);
      this.next_trigger.style.cursor = 'pointer';
    }
  },

  slideable: function(coords) {
    var top = parseInt(this.elements.style.top) || 0;
    var left = parseInt(this.elements.style.left) || 0;

    if ((coords.y > 0 && top >= 0) || (coords.x > 0 && left >= 0))
      return false;

    if ((coords.y < 0 && -top > this.elements.getHeight() - this.container.getHeight()) ||
        (coords.x < 0 && -left > this.elements.getWidth() - this.container.getWidth()))
      return false;

    return true;
  },

  slide: function(coords, event) {
    event.stop();

    if (this.sliding || !this.slideable(coords))
      return;

    this.sliding = true;
    new Effect.Move(this.elements, {
      x: coords.x,
      y: coords.y,
      mode: 'relative',
      transition: Effect.Transitions.sinoidal,
      duration: 0.3,
      afterFinish: this.b_afterSlide
    });
  },

  afterSlide: function() {
    this.updateTriggers();
    this.sliding = false;
  }

});

