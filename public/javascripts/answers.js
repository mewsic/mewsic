document.observe('dom:loaded', function() {
  $w("open top newest search").each(function(name) {
    if (!$(name + '-answers-container'))
      return;

    new Pagination({
      container: name + '-answers-container',
      spinner: name + '-answers-spinner',
      selector: '.pagination.answers a',
      onComplete: function() {
        new Effect.ScrollTo(name + '-answers-container', {
          offset: -40
        });
      }
    });
  });  
});
