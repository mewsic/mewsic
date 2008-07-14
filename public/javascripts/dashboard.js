var Splash = Class.create({
  initialize: function() {
    this.updater = new PeriodicalExecuter(this.cycle.bind(this), 10);
  },
  
  cycle: function() {
    new Effect.Parallel([
      new Effect.Fade('splash_tracks', {sync: true}),
      new Effect.Fade('splash_songs', {sync: true})
      ], { duration: 0.4 }
    );
    
    $('splash_tracks_spinner').show();
    $('splash_songs_spinner').show();

    /*
    $('splash_tracks').setOpacity(0.2);
    $('splash_songs').setOpacity(0.2);
    $('splash_tracks_spinner').appear({duration: 0.3});
    $('splash_songs_spinner').appear({duration: 0.3});
    */

    this.request.bind(this).delay(1.5);
  },

  request: function() {
    $('splash_motto').down('h2').fade({duration: 0.3});
    new Ajax.Request('/splash', {
      method: 'get',
      onCreate: function() {
        var mlabSlider = MlabSlider.getInstance();        
        if (mlabSlider) {
          mlabSlider.releaseTrackButtons(true, $('splash_tracks'));
          mlabSlider.releaseSongButtons(true, $('splash_songs'));
        }
      }.bind(this),
      onComplete: this.complete.bind(this)
    });
  },

  complete: function(r) {
    $('splash_container').update(r.responseText);

    $('splash_tracks_spinner').hide();
    $('splash_songs_spinner').hide();

    var mlabSlider = MlabSlider.getInstance();        
    if (mlabSlider) {
      mlabSlider.initTrackButtons(true, $('splash_tracks'));
      mlabSlider.initSongButtons(true, $('splash_songs'));
    }

  },

  appear: function(r) {
    /*
    new Effect.Parallel([
      new Effect.Fade('splash_tracks_spinner', {sync: true}),
      new Effect.Fade('splash_songs_spinner', {sync: true}),
      new Effect.Appear('splash_tracks', {sync: true}),
      new Effect.Appear('splash_songs', {sync: true})
      ], { duration: 0.5 }
    );
    $('splash_tracks_spinner').hide();//fade({duration: 0.2});
    $('splash_songs_spinner').hide();//fade({duration: 0.2});
    $('splash_tracks').setOpacity(1.0);
    $('splash_songs').setOpacity(1.0);
    */
  }
});

document.observe('dom:loaded', function() {
  Splash.instance = new Splash();
});
