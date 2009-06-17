$(function() {
	/* ROUNDED CORNERS CLASSES */
	$('.roundTop10').corner("top 10px");
	$('.roundBottom10').corner("bottom 10px");
	$('.round10').corner("cc:#ffffff 10px");
	$('.round7').corner("cc:#ffffff 7px");		

  applesearch.init();
});


// Facebook connect stuff
//
function initializeFacebook() {
  try {

    //FB_RequireFeatures(["XFBML", "CanvasUtil", "Api"], function(){
      FB.init('8b03aa5c7dae2e65e155bdcd41634d25', '/sessions/connect');
    //});

  } catch(e) {
    if (isLoggerAvailable())
      console.log("Facebook connect support is not available");

    $('#facebook-connect-button').hide();
  }

}

function reload() {
  window.location.href = window.location.href;
}

function isLoggerAvailable() {
  var ret = false; try { ret = console.log != undefined; } catch (e) {}; return (ret);
}



/// LIBRARY, move in separate file
//
$.fn.addErrorIfEmpty = function() {
  return this.filter(function() {
    if ($(this).val() == '') {
      $(this).addClass('error');
      return true;
    }
  });
}

$.fn.addErrorWhenEmptied = function() {
  var checkEmpty = function() {
    if ($(this).val() == '')
      $(this).addClass('error');
    else
      $(this).removeClass('error');
  };

  return this.each(function() {
    $(this).blur(checkEmpty).focus(function() {
      if (!this.firstChecked)
        this.firstChecked = true;
      else
        checkEmpty();
    });
  });
}

$.fn.hideDefaultValueOnBlur = function() {
  return this.each(function() {
    var self = $(this);
    var defaultValue = self.attr('value');

    self.focus(function() {
      if(self.attr('value') == defaultValue) {
        self.attr('value', '');
      }
    }).blur(function() {
      if(self.attr('value') == '') {
        self.attr('value', defaultValue);
      }
    });

  });
}

$.rand = function() {
	return Math.pow(Math.random()*10, 10);
}

$.randInt = function() {
	return Math.floor($.rand());
}

$.randInt(); // Seed it.

$.fn.fadeTo = function(amount) {
	var params = arguments[1] || {duration: 'slow'};

	return this.each(function() {
		$(this).animate({opacity: amount}, params)
	});
}
