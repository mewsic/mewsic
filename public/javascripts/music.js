document.observe('dom:loaded', function() {
  var name = $('genres') ? 'genres' : 'songs';

  new Pagination({
    container: name,
    spinner: name + '-spinner',
    selector: 'a.genre-pagination',
    onComplete: function() {
      new Effect.ScrollTo(name, {duration:1.0});
    }
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
