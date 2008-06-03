var Splash = {
  
  update: function() {
    new Ajax.Request('/splash', {
      method: 'get',
      onComplete: function(r) {
        $('splash_container').update(r.responseText);
        var mlabSlider = MlabSlider.getInstance();        
        mlabSlider.initTrackButtons(true);
        //mlabSlider.initSongButtons(true);
      }
    });
  }
     
};

document.observe('dom:loaded', function() {
  new PeriodicalExecuter(Splash.update, 10);
});