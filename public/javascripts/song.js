var Scrollers = {};

document.observe('dom:loaded', function() {
  Scrollers.song = new SimpleSlider('song-tracks-container');
  Scrollers.direct = new SimpleSlider('direct-siblings-tracks-scroller');
  Scrollers.indirect = new SimpleSlider('indirect-siblings-tracks-scroller');
});
