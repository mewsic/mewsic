document.observe('dom:loaded', function() {
  new SimpleSlider('most-instruments-scroller', {x: 210, y: 0});
  new SimpleSlider('most-friends-scroller', {x: 210, y: 0});

  new Refresher('most-friends', {
    onComplete: function() {
      new SimpleSlider('most-friends-scroller', {x: 210, y: 0});
    }
  });
  new Refresher('most-instruments', {
    onComplete: function() {
      new SimpleSlider('most-instruments-scroller', {x: 210, y: 0});
    }
  });
});

