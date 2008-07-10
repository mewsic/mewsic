Ajax.Responders.register({
  onComplete: function() {
    if ($('mix-song-form')) {
      if (SongMix.instance) {
        if (!SongMix.instance.processing) {
          SongMix.instance.dispose();
          SongMix.instance = new WorkerClient('mix-song-form');
        }
      } else {
        SongMix.instance = new WorkerClient('mix-song-form');
      }
    }
  }
});
