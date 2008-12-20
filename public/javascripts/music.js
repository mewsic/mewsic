document.observe('dom:loaded', function() {
  var name = $('genres') ? 'genres' : 'songs';

  new Pagination({
    container: name,
    spinners: $w(name + '-spinner-top ' + name + '-spinner-bottom'),
    selector: 'a.genre-pagination',
    onComplete: function() {
      new Effect.ScrollTo(name, {duration:1.0});
    }
  });

  $w('newest').each(function(name) {
    if (!$(name + '-music'))
      return;

    new Pagination({
      container: name + '-music',
      spinners: [name + '-spinner-top', name + '-spinner-bottom'],
      selector: 'a.navigation',
      dynamic_spinner: false,
      onComplete: function() {
        new Effect.ScrollTo(name + '-music', {duration: 0.7});
      }
    });
  });

  if ($('genres')) {
    new Refresher('best-songs', {
      image: '/images/bestsong_refresh.gif',
      spinner: '/images/bestsongs_spinner.gif'
    });
    new Refresher('most-used-tracks', {
      image: '/images/mostused_refresh.gif',
      spinner: '/images/mostused_spinner.gif'
    });
  }
});
