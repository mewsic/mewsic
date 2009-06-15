$.fn.replaceOnClickWith = function(options) {
  var spinner = '<div class="fright icons16 loader_white" style="margin:auto auto;"></div>';

  var selector = $(this).selector;
  var before = function() { $(selector).empty().append(spinner); };
  var after = function(html) { $(selector).replaceWith(html); };

  $(this).find(options.anchor).click(function() {
    $.ajax({
      url: options.url,
      beforeSend: before,
      success: after
    });
    return false;
  });

  $(this).find('form').submit(function() {
    $(this).ajaxSubmit({
      url: options.url,
      type: 'PUT',
      beforeSubmit: before,
      success: after
    });
    return false;
  });
};

$.fn.simpleTabs = function() {
  var container = $(this);
  var choices = container.children('ul');
	var options = arguments[0] || {};
  var current = options.current || 'current';

  choices.find('li a').click(function() {
    choices.find('li').removeClass(current);
    container.children('div').hide();

    $(this).parent('li').addClass(current);
    $($(this).attr('href')).show();
    return false;
  })

  return this;
};
