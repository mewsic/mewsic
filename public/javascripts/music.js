document.observe('dom:loaded', function() {
  var name = $('genres') ? 'genres' : 'songs';

  new Pagination({
    container: name,
    spinner: name + '-spinner',
    selector: 'a.genre-pagination',
    update_mlab: true
  });

  if ($('genres')) {
    new Refresher('best-songs', {
      image: '/images/bestsong_refresh.png',
      spinner: '/images/bestsongs_spinner.gif'
    });
    new Refresher('most-used-tracks', {
      image: '/images/mostused_refresh.png',
      spinner: '/images/mostused_spinner.gif'
    });
  }
});
