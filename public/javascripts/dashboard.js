var Splash = {
  
  update: function() {
    new Ajax.Request('/splash', {
      method: 'get',
      onComplete: function(r) {
        var splash = $('splash_container');
        $$('.splash .instrument').each(function(element) {
          Tips.remove(element);
        });
        new Effect.Parallel([new Effect.Fade('splash_tracks'),new Effect.Fade('splash_songs')], { 
          duration: 0.5,
          afterFinish: function() {
            splash.update(r.responseText);
            new Effect.Parallel([new Effect.Appear('splash_tracks'), new Effect.Appear('splash_songs')], { duration: 0.5 });
          }
        });
        
        var mlabSlider = MlabSlider.getInstance();        
        if (mlabSlider) {
          mlabSlider.initTrackButtons(true);
          mlabSlider.initSongButtons(true);
        }        
        splash.descendants().select('.instrument').each(function(element) {
          new Tip(element, element.getAttribute('rel'));
        });
      }
    });
  }
     
};

document.observe('dom:loaded', function() {
  new PeriodicalExecuter(Splash.update, 10);
});
