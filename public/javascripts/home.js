/* JQUERY UI */
$(function() {
	$("#playlist_tabs").tabs();
});



$(function() {
	$("#expl_hide").click(function () {
		$('#expl_banner').hide("blind", {}, 1000);
	});
});	




/* SIGN UP - JOIN NOW */
$(function() {
	
	var name = $("#name"),
		email = $("#email"),
		password = $("#password"),
		allFields = $([]).add(name).add(email).add(password),
		tips = $("#validateTips");

	function updateTips(t) {
		tips.text(t).effect("highlight",{},3500);
	}

	function checkLength(o,n,min,max) {

		if ( o.val().length > max || o.val().length < min ) {
			o.addClass('ui-state-error');
			updateTips("Length of " + n + " must be between "+min+" and "+max+".");
			return false;
		} else {
			return true;
		}

	}

	function checkRegexp(o,regexp,n) {

		if ( !( regexp.test( o.val() ) ) ) {
			o.addClass('ui-state-error');
			updateTips(n);
			return false;
		} else {
			return true;
		}

	}
	
	$("#dialog").dialog({
		autoOpen: false,
		dialogClass: 'dialog_join',
		modal: true,
		width: 350,
		resizable: false,
		buttons: {
			'Create an account': function() {
				var bValid = true;
				allFields.removeClass('ui-state-error');

				bValid = bValid && checkLength(name,"username",3,16);
				bValid = bValid && checkLength(email,"email",6,80);
				bValid = bValid && checkLength(password,"password",5,16);

				bValid = bValid && checkRegexp(name,/^[a-z]([0-9a-z_])+$/i,"Username may consist of a-z, 0-9, underscores, begin with a letter.");
				// From jquery.validate.js (by joern), contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/
				bValid = bValid && checkRegexp(email,/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i,"eg. ui@jquery.com");
				bValid = bValid && checkRegexp(password,/^([0-9a-zA-Z])+$/,"Password field only allow : a-z 0-9");
				
				if (bValid) {
					$('#users tbody').append('<tr>' +
						'<td>' + name.val() + '</td>' + 
						'<td>' + email.val() + '</td>' + 
						'<td>' + password.val() + '</td>' +
						'</tr>'); 
					$(this).dialog('close');
				}
			},
			Cancel: function() {
				$(this).dialog('close');
			}
		},
		close: function() {
			allFields.val('').removeClass('ui-state-error');
		}
	});
		
	
	$('#create-user').click(function() {
		$('#dialog').dialog('open');
	})

});



/* CHANGE AVATAR */
$(function() {
	$("#change_avatar").dialog({
		autoOpen: false,
		dialogClass: 'change_avatar',
		modal: true,
		width: 550,
		resizable: false
	})
	
	$('#avatar_dialog').click(function() {
		$('#change_avatar').dialog('open');
	})
	
});

	// JCROP
	// Remember to invoke within jQuery(window).load(...)
	// If you don't, Jcrop may not initialize properly
	jQuery(window).load(function(){

		jQuery('#cropbox').Jcrop({
			onChange: showPreview,
			onSelect: showPreview,
			aspectRatio: 1
		});

	});

	// Our simple event handler, called from onChange and onSelect
	// event handlers, as per the Jcrop invocation above
	function showPreview(coords)
	{
		var rx = 200 / coords.w;
		var ry = 200 / coords.h;

		jQuery('#preview').css({
			width: Math.round(rx * 380) + 'px',
			height: Math.round(ry * 600) + 'px',
			marginLeft: '-' + Math.round(rx * coords.x) + 'px',
			marginTop: '-' + Math.round(ry * coords.y) + 'px'
		});
	}



/* SHARE TO WALL */
$(function() {
	$("#share_songs_dialog").dialog({
		autoOpen: false,
		dialogClass: 'share_song',
		modal: true,
		width: 450,
		resizable: false,
		buttons: {
					Attach: function() {
					$(this).dialog('close');
					}
				}
	});
	
	$('#share_song_link').click(function() {
		$('#share_songs_dialog').dialog('open');
	});
	
});

$(function() {

	/* WALL, SHARE MEDIA */
	$("#share_media_dialog").dialog({
		autoOpen: false,
		dialogClass: 'share_media',
		modal: true,
		width: 450,
		resizable: false
	});
	
	$('#share_picture_link').click(function() {
		$('#share_media_dialog').dialog('open');
	});
	
	$('#share_video_link').click(function() {
		$('#share_media_dialog').dialog('open');
	});
	
	
	/* TAGGING DIALOG */
	$("#add_tags").dialog({
		autoOpen: false,
		dialogClass: 'tagging',
		modal: true,
		width: 510,
		resizable: false,
		buttons: {
					Save: function() {
					$(this).dialog('close');
					},
					Cancel: function() {
					$(this).dialog('close');
					}					
				}		
	});

	$('#add_tags_link').click(function() {
		$('#add_tags').dialog('open');
	});

});
