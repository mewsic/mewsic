var GenrePagination = Class.create({
  initialize: function() {
    this.authenticity_token = $('authenticity-token').value;
    this.b_paginate = this.paginate.bind(this);

    this.initLinks();
  },

  initLinks: function() {
    this.spinner = $('genre-spinner');

    this.links = [$('genre-links').down('.next-genre'),
                  $('genre-links').down('.prev-genre'),
                  $('genre-chars').select('a')].flatten();

    this.links.each(function(link) {
      link.observe('click', this.b_paginate);
    }.bind(this));
  },

  paginate: function(event) {
    var element = event.element();
    if (element.tagName != 'A') {
      element = element.up('a');
    }

    var letter = element.getAttribute('rel');

    event.stop();

    new Ajax.Updater('genres', '/genres.html', {
      method: 'get',
      parameters: { c: letter, authenticity_token: this.authenticity_token },
      onLoading: this.loading.bind(this),
      onComplete: this.complete.bind(this)
    });
  },

  loading: function() {
    this.spinner.show();

    this.links.each(function(link) {
      link.stopObserving('click', this.b_paginate);
    }.bind(this));
  },

  complete: function() {
    this.initLinks();

    var mlabSlider = MlabSlider.getInstance();
    if (mlabSlider) {
      mlabSlider.initSongButtons(true);
    }

    this.spinner.hide();
  }
});

document.observe('dom:loaded', function() {
  GenrePagination.instance = new GenrePagination();
});
