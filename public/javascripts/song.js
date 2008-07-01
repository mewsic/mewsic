var TrackSlider = Class.create({
  initialize: function() {
    this.tracks = $('song-tracks-container');
    this.container = this.tracks.up();

    this.prev = $('slide-prev');
    this.next = $('slide-next');

    this.prev.observe('click', this.slide.bind(this, 300));
    this.next.observe('click', this.slide.bind(this, -300));
  },

  slide: function(y, event) {
    event.stop();

    if (this.sliding)
      return;

    if (y > 0 && parseInt(this.tracks.style.top) >= 0)
      return;

    if (y < 0 && -parseInt(this.tracks.style.top) > this.tracks.getHeight() - this.container.getHeight())
      return;

    this.sliding = true;
    new Effect.Move(this.tracks, {
      x: 0, y: y, mode: 'relative', transition: Effect.Transitions.sinoidal,
      duration: 0.3, afterFinish: function() { this.sliding = false }.bind(this)
    });
  }

});

document.observe('dom:loaded', function() {
  TrackSlider.instance = new TrackSlider();
});
