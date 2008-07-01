var TrackSlider = Class.create({
  initialize: function(element) {
    this.elements = $(element);
    this.container = this.elements.up();

    var outer = this.elements.up('.slide-container');

    outer.select('.slide-prev').each(function(element) {
      element.observe('click', this.slide.bind(this, 300));
    }.bind(this));

    outer.select('.slide-next').each(function(element) {
      element.observe('click', this.slide.bind(this, -300));
    }.bind(this));
  },

  slide: function(y, event) {
    event.stop();

    if (this.sliding)
      return;

    if (y > 0 && parseInt(this.elements.style.top) >= 0)
      return;

    if (y < 0 && -parseInt(this.elements.style.top) > this.elements.getHeight() - this.container.getHeight())
      return;

    this.sliding = true;
    new Effect.Move(this.elements, {
      x: 0, y: y, mode: 'relative', transition: Effect.Transitions.sinoidal,
      duration: 0.3, afterFinish: function() { this.sliding = false }.bind(this)
    });
  }

});

document.observe('dom:loaded', function() {
  $w('song-tracks-container direct-sibling-tracks indirect-sibling-tracks').each(function(element) {
    new TrackSlider(element);
  });
});
