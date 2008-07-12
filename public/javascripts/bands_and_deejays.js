document.observe('dom:loaded', function() {
  new SimpleSlider('most-instruments-scroller', {x: 210, y: 0});
  new SimpleSlider('most-friends-scroller', {x: 210, y: 0});

  new Refresher('most_friends');
  new Refresher('most_instruments');
});

