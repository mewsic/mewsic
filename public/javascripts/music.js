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

  if ($('newest')) {
    new Pagination({
      container: 'newest',
      selector: 'a.navigation',
      spinners: $w('songs-spinner-top songs-spinner-bottom'),
      onComplete: function() {
        new Effect.ScrollTo('newest', {duration: 1.0});
      }
    });
  }

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
