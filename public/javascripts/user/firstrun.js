document.observe('dom:loaded', function() {
  Lightview.show({
    href: '/users/' + $('current-user-id').value + '/firstrun',
    rel: 'iframe',
    options: {
      autosize: false,
      width: 410,
      height: 360,
      topclose: true
    }
  });
});
