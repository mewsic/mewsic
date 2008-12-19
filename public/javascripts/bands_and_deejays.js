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

  $w('newest coolest prolific best').each(function(name) {
    if (!$(name + '-users'))
      return;

    new Pagination({
      container: name + '-users',
      spinners: [name + '-spinner-top', name + '-spinner-bottom'],
      selector: 'a.navigation',
      dynamic_spinner: false,
      onComplete: function() {
        new Effect.ScrollTo(name + '-users', {duration: 0.7});
      }
    });
  });

});
