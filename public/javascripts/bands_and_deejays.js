document.observe('dom:loaded', function() {
  new SimpleSlider('coolest-mband-scroller', {x: 210, y: 0});
  new SimpleSlider('most-instruments-scroller', {x: 210, y: 0});
  new SimpleSlider('most-admirers-scroller', {x: 210, y: 0});

  new Refresher('most-admirers', {
    onComplete: function() {
      new SimpleSlider('most-admirers-scroller', {x: 210, y: 0});
    }
  });
  new Refresher('most-instruments', {
    onComplete: function() {
      new SimpleSlider('most-instruments-scroller', {x: 210, y: 0});
    }
  });
  new Refresher('coolest-mbands', {
    onComplete: function() {
      new SimpleSlider('coolest-mband-scroller', {x: 210, y: 0});
    }
  });
});
