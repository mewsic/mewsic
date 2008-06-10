var Splash = {
  
  update: function() {
    new Ajax.Request('/splash', {
      method: 'get',
      onComplete: function(r) {
        var splash = $('splash_container');
        $$('.splash .instrument').each(function(element) {
          Tips.remove(element);
        });

        splash.update(r.responseText);

        var mlabSlider = MlabSlider.getInstance();        
        if (mlabSlider) {
          mlabSlider.initTrackButtons(true);
          //mlabSlider.initSongButtons(true);
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
