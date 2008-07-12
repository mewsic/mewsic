document.observe('dom:loaded', function() {
  new SimpleSlider('coolest-mband-scroller', {x: 210, y: 0});
  new SimpleSlider('most-instruments-scroller', {x: 210, y: 0});
  new SimpleSlider('most-friends-scroller', {x: 210, y: 0});

  new Refresher('most_friends', {
    onComplete: function() {
      new SimpleSlider('most-friends-scroller', {x: 210, y: 0});
    }
  });
  new Refresher('most_instruments', {
    onComplete: function() {
      new SimpleSlider('most-instruments-scroller', {x: 210, y: 0});
    }
  });
  new Refresher('coolest_mbands', {
    onComplete: function() {
      new SimpleSlider('coolest-mband-scroller', {x: 210, y: 0});
    }
  });
});
