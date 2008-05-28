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
		new Effect.Appear(this.popup, {duration: 0.3});

		element = event.element();
		if (element.tagName == 'IMG')
		  element = element.up('a.button.popup');

		this.loadPage(element.getAttribute('href'));
	},

	handleClosePopup: function(event) {
		event.stop();
		new Effect.Fade(this.popup, {
			duration: 0.3,
			afterFinish: function() { this.container.update(''); }.bind(this) });
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
		MSNProxy.instance.setupLinks();
		this.spinner.hide();
	}
});

var MSNProxy = Class.create({
  initialize: function() {
		this.app = new Element('object', {height:0,width:0});

		try {
			this.app.classid = "clsid:B69003B3-C55E-4B48-836C-BC5946FC3B28";
			this.status = this.app.MyStatus;
			this.msn_present = this.status != null;
		}
		catch (e) {
			this.msn_present = false;
		}
	},

	setupLinks: function() {
		$$('a.msn-link').invoke('observe', 'click', this.onMSNClick.bind(this));
	},

	onMSNClick: function(event) {
		event.stop();

		if (!this.msn_present)
			return;

		if (this.app.MyStatus == 1) {
			alert("You have to log in to MSN for this to work!");
			return;
		}

		var element = event.element();
		if (element.tagName == 'IMG')
			element = element.up('a.msn-link');

		this.app.addContact(0, element.getAttribute('rel'));
	}
});

document.observe('dom:loaded', function() {
	IMBox.instance = new IMBox();
	MSNProxy.instance = new MSNProxy();
});
