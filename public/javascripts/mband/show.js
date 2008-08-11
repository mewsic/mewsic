document.observe('dom:loaded', function() {
  $w('tracks songs').each(function(name) {
    if (!$(name))
      return;

    new Pagination({
      container: name,
      spinner: name + '_spinner',
      selector: 'a.navigation',
      dynamic_spinner: true,
      update_mlab: true
    });
  });

  function stopEvent(event) {
    event.stop();
  }

  var link = $('podcast-link');
  var tip = null;
  if (link) {
    var contents = $(link.getAttribute('rel'));
    link.observe('click', stopEvent);
    tip = new Tip (link, contents, {style: 'user-link', title: link.title});
  }

  function destroy() {
    tip.closeButton = null;
    tip.content = null;
    tip.element = null;
    tip.target = null;
    tip.tip = null;
    tip.title = null;
    tip.wrapper = null;
    tip.iframeShim = null;
    tip.tooltip = null;
    tip.toolbar = null;
    tip.stem = null;
    tip.stemBox = null;
    tip.stemImage = null;
    tip.stemWrapper = null;
    tip.borderBottom = null;
    tip.borderCenter = null;
    tip.borderFrame = null;
    tip.borderMiddle = null;
    tip.borderTop = null;

    tip.options.target = null;
    tip.options = null;

    tip = null;

    link.stopObserving('click', stopEvent);
    link = null;
  }
  Event.observe(window, 'unload', destroy.bind(this));
});
