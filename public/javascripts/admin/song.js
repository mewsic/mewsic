var SongMix = {};

Ajax.Responders.register({
  onComplete: function() {
    if (!$('mix-song-form')) {
      return;
    }

    if (SongMix.instance && !SongMix.instance.processing) {
      SongMix.instance.dispose();
    }

    SongMix.instance = new WorkerClient('mix-song-form', {
      onComplete: function(worker) {
        $('song_seconds').value = worker.length;
        $('song_filename').value = worker.output;
      }
    });
  }
});
