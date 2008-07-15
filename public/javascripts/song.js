document.observe('dom:loaded', function() {
  $w('song-tracks-container direct-sibling-tracks indirect-sibling-tracks').each(function(element) {
    new SimpleSlider(element, {x:0, y:305});
  });
});
