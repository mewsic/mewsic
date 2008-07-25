document.observe('dom:loaded', function() {
  if ($('current-user-id') && window.location.href.split(/\?/)[1] == 'welcome') {
    Lightview.show({
      href: '/users/' + $('current-user-id').value + '/firstrun',
      rel: 'iframe',
      options: {
        topclose: false,
        autosize: false,
        width: 410,
        height: 360
      }
    });
  }
});
