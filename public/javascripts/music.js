document.observe('dom:loaded', function() {
  var name = $('genres') ? 'genres' : 'songs';

  new Pagination({
    container: name,
    spinner: name + '-spinner',
    selector: 'a.genre-pagination',
    update_mlab: true,
    onComplete: function() { setupStarboxes('#' + name + ' .rating') }
  });
});
