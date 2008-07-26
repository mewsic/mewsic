var TrackUpload = Class.create(WorkerClient, {
  responder: function(xml) {
    var r = {responseXML: (new DOMParser()).parseFromString(xml, "application/xml")};
    if (!this.updater) {
      // First request
      this.startUpdater(r);
      $('track-upload-iframe').hide();
      $('Filedata').value = '';
    } else {
      this.showWorkerStatus(r);
    }

  },

  startUpdater: function($super, r) {
    $super(r);
    $('worker').value = this.worker.key;
  },

  cycle: function(key) {
    this.showLoading();
    this.mix_form.submit();
  },

  onMix: function(event) {
    this.processing = true;
  }
});

Ajax.Responders.register({
  onComplete: function() {
    if (!$('track-upload-form')) {
      return;
    }

    if (TrackUpload.instance && !TrackUpload.instance.processing) {
      TrackUpload.instance.dispose();
    }

    TrackUpload.instance = new TrackUpload('track-upload-form', {
      onComplete: function(worker) {
        $('track_seconds').value = worker.length;
        $('track_filename').value = worker.output.sub(/^\/audio\//, '');
      }
    });
  }
});
