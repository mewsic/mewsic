$.fn.replaceOnClickWith = function(options) {
  var selector = $(this).selector;
  $(this).find(options.anchor).click(function() {
    $.ajax({
      url: options.url,
      beforeSend: function() { $(selector).empty().append('loading...'); },
      success: function(html) { $(selector).replaceWith(html); }
    });
    return false;
  });
}
