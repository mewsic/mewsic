document.observe('dom:loaded', function() {
  new SimpleSlider('song-tracks-container');
  new SimpleSlider('direct-siblings-tracks-scroller');
  new SimpleSlider('indirect-siblings-tracks-scroller');
});
