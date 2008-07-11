var WorkerClient = Class.create({

  template_html: '<dl><dt>key</dt><dd>#{key}</dd><dt>status</dt><dd>#{status}</dd><dt>filename</dt><dd>#{output}</dd><dt>length</dt><dd>#{length}</dd></dl>',

  initialize: function(element, options) {
    this.mix_form = $(element);
    this.b_onMix = this.onMix.bind(this);
    this.mix_form.observe('submit', this.b_onMix);
    this.container = this.mix_form.down('.container');
    this.template = new Template(this.template_html);
    this.processing = false;
    this.options = options || {};
  },

  onMix: function(event) {
    event.stop();
    this.mix_form.down('input[type=submit]').disabled = true;
    this.processing = true;

    new Ajax.Request(this.mix_form.action, {
      method: 'post', evalScripts: false,
      parameters: Form.serialize(this.mix_form) +
        '&authenticity_token=' + encodeURIComponent($('authenticity_token').value),
      onLoading: this.showLoading.bind(this),
      onSuccess: this.startUpdater.bind(this),
      onFailure: this.error.bind(this)
    });
  },

  startUpdater: function(r) {
    this.showWorkerStatus(r);
    this.worker = this.parseWorkerStatus(r.responseXML);
    this.updater = new PeriodicalExecuter(this.cycle.bind(this, this.worker.key), 2);
  },

  cycle: function(key) {
    new Ajax.Request(this.mix_form.action, {
      method: 'post', evalScripts: false,
      parameters: { worker: key, authenticity_token: $('authenticity_token').value },
      onLoading: this.showLoading.bind(this),
      onFailure: this.error.bind(this),
      onSuccess: this.showWorkerStatus.bind(this)
    });
  },

  showLoading: function() {
    this.container.show();
    this.container.update('<img src="/images/spinner.gif"/>');
  },

  showWorkerStatus: function(r) {
    var worker = this.parseWorkerStatus(r.responseXML);
    this.container.update(this.template.evaluate(worker));

    if(worker.status == 'finished') {
      this.stop();
      if (this.options.onComplete) {
        this.options.onComplete(worker);
      }
    }
  },

  error: function(r) {
    this.container.update(r.responseText);
    this.stop();
  },

  dispose: function() {
    this.stop();
    this.mix_form.stopObserving('submit', this.b_onMix);
    this.mix_form.down('input[type=submit]').disabled = false;
  },

  stop: function() {
    this.processing = false;
    if (this.updater) {
      this.updater.stop();
    }
  },

  parseWorkerStatus: function(doc) {
    var worker = doc.childNodes[0];
    return({
      key: worker.getAttribute('key'),
      status: worker.getElementsByTagName('status')[0].textContent || 'initializing',
      output: worker.getElementsByTagName('output')[0].textContent,
      length: worker.getElementsByTagName('length')[0].textContent
    });
  },

  __dummy__: function() {}
});


