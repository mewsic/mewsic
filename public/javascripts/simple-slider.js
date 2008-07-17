var SimpleSlider = Class.create({
  initialize: function(element, options) {
    this.outer = $(element);
    if (!this.outer)
      return;

    coords = Object.extend({
      x: 0,
      y: 300
    }, options);

    this.container = this.outer.down('div.slide-container');
    this.elements = this.container.down('div.slide-contents');

    this.outer.down('a.slide-prev').observe('click', this.slide.bind(this, coords));
    this.outer.down('a.slide-next').observe('click', this.slide.bind(this, {x: -coords.x, y: -coords.y}));
  },

  slide: function(coords, event) {
    event.stop();

    if (this.sliding)
      return;

    var top = parseInt(this.elements.style.top);
    var left = parseInt(this.elements.style.left);

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

