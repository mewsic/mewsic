var IMBox = Class.create({

  initialize: function() {
    this.element = $('user-links');
    this.authenticity_token = $('authenticity-token').value;
		this.popup = this.element.down('div.popup');
		this.container = this.element.down('div.container');
		this.spinner = this.element.down('img.popup-spinner');
		this.element.select('a.button.popup').invoke('observe', 'click', this.handleOpenPopup.bind(this));
		this.popup.down('a.button.close').observe('click', this.handleClosePopup.bind(this));
	},

	handleOpenPopup: function(event) {
		event.stop();
		this.popup.show();
		this.container.show();

		element = event.element();
		if (element.tagName == 'IMG')
		  element = element.up('a.button.popup');

		this.loadPage(element.getAttribute('href'));
	},

	handleClosePopup: function(event) {
		event.stop();
		this.popup.hide();
		this.container.update('').hide();
	},

	loadPage: function(url) {
		var options = Object.extend({
			method: 'get',
			evalScripts: true,
			onLoading: this.handlePageLoading.bind(this),
			onComplete: this.handlePageLoaded.bind(this)
		}, arguments[1] || {});
		new Ajax.Updater(this.container, url, options);
	},

	handlePageLoading: function() {
		this.spinner.show();
	},

	handlePageLoaded: function() {
		this.spinner.hide();
	}
});

document.observe('dom:loaded', function() {
	IMBox.instance = new IMBox();
});
