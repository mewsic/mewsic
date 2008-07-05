document.observe('dom:loaded', function() {
  $$('a.menu-link').each(function(link) {
    link.observe('click', function(event) {
      var element = event.element();
      event.stop();

      $$('a.menu-link').invoke('removeClassName', 'active');
      element.addClassName('active');

      new Ajax.Updater('admin_content', element.href, {
        method: 'get',
        parameters: { authenticity_token: $('authenticity_token').value }
      });
    });
  });

  Ajax.Responders.register({
    onLoading: function() { $('spinner').show(); },
    onComplete: function() { $('spinner').hide(); }
  });

  Ajax.Responders.register({
    onComplete: function(r) {
      var container = $(r.container.success);
      if (container.id == 'editing') {
        container.down('a.close-edit').observe('click', function(event) {
          event.stop();
          $('editing').fade({duration: 0.3});
        });
      }
      container.select('a.edit-link').each(function(link) {
        link.observe('click', function(event) {
          event.stop();

          var row = event.element().up('tr');
          if (row) {
            // we're in a table
            $$('.admin_content_table tr.active').invoke('removeClassName', 'active');
            row.addClassName('active');
            $('editing').style.top = String(row.offsetTop) + 'px';
          }

          $('editing').update('');
          new Ajax.Updater('editing', event.element().href, {
            method: 'get',
            onComplete: function() {
              if (!$('editing').visible()) {
                $('editing').appear({duration: 0.3});
              }
              //new Effect.ScrollTo('editing', {duration: 0.2});
            }
          });
        });
      });
    }
  });
});
