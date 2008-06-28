var Splash = Class.create({
  initialize: function() {
    this.updater = new PeriodicalExecuter(this.request.bind(this), 10);
  },
  
  request: function() {
    new Ajax.Request('/splash', {
      method: 'get',
      onLoading: this.loading,
      onComplete: this.complete.bind(this)
    });
  },

  loading: function() {
    new Effect.Parallel([
      new Effect.Fade('splash_tracks', {sync: true}),
      new Effect.Fade('splash_songs', {sync: true}),
      new Effect.Appear('splash_tracks_spinner', {sync: true}),
      new Effect.Appear('splash_songs_spinner', {sync: true})
      ], { duration: 0.5 }
    );
  },

  complete: function(r) {
    this.refresh.delay(1.5, r);
  },

  refresh: function(r) {
    $('splash_container').update(r.responseText);

    new Effect.Parallel([
      new Effect.Fade('splash_tracks_spinner', {sync: true}),
      new Effect.Fade('splash_songs_spinner', {sync: true}),
      new Effect.Appear('splash_tracks', {sync: true}),
      new Effect.Appear('splash_songs', {sync: true})
      ], { duration: 0.5 }
    );
        
    var mlabSlider = MlabSlider.getInstance();        
    if (mlabSlider) {
      mlabSlider.initTrackButtons(true);
      mlabSlider.initSongButtons(true);
    }
  }
});

document.observe('dom:loaded', function() {
  Splash.instance = new Splash();
});
