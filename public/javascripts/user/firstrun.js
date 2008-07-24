document.observe('dom:loaded', function() {
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
});
