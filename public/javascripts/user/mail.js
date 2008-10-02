var MailBox = Class.create({
  
  initialize: function() {
    this.element = $('user-mail');
    this.authenticity_token = $('authenticity-token').value;

    this.popup = this.element.down('div.popup');
    this.container = this.popup.down('div.container');

    this.b_handleOpenPopup = this.handleOpenPopup.bind(this);
    this.b_handleClosePopup = this.handleClosePopup.bind(this);

    this.element.select('a.button.popup').invoke('observe', 'click', this.b_handleOpenPopup);
    this.popup.down('a.button.close').observe('click', this.b_handleClosePopup);

    if ($('current-user-page')) {
      this.b_handleInboxLink = this.handleInboxLink.bind(this);
      $('inbox-link').observe('click', this.b_handleInboxLink);
    }
    Event.observe(window, 'unload', this.destroy.bind(this));
  },

  destroy: function() {
    this.element.select('a.button.popup').invoke('stopObserving', 'click', this.b_handleOpenPopup);
    this.popup.down('a.button.close').stopObserving('click', this.b_handleClosePopup);

    if (this.b_handleInboxLink);
      $('inbox-link').stopObserving('click', this.b_handleInboxLink);

    this.popup = null;
    this.element = null;
    this.container = null;
  },
  
  updateReceivedCount: function(count) {
    this.element.down('.received.count').update(count);
  },
  
  updateUnreadCount: function(count) {
    this.element.down('.unread.count').update(count);
    $('inbox-link').update("inbox (" + count + ")");
  },
  
  handleClosePopup: function(event) {
    event.stop();
    this.closePopup();
  },
  
  closePopup: function() {
    this.deselectAllLinks();
    new Effect.Fade(this.popup, {
      duration: 0.3,
      afterFinish: function() { this.container.update(''); }.bind(this)
    });
  },
  
  handleOpenPopup: function(event) {
    event.stop();
    this.deselectAllLinks();
    event.element().up().addClassName('active');
    event.element().up().up().addClassName('active');
    this.openPopup();
    this.loadPage(event.element().getAttribute('href'));
  },
  
  openPopup: function() {
    new Effect.Appear(this.popup, {duration: 0.3});
  },
  
  deselectAllLinks: function() {
    this.element.select('.active').invoke('removeClassName', 'active');
  },
  
  initPaginationLinks: function() {
    this.popup.select('div.pagination a').invoke('observe', 'click', this.onClickPage.bind(this));
    this.popup.select('a.ajax').invoke('observe', 'click', this.onClickPage.bind(this));
    this.popup.select('a.destroy').each(function(link) {
      link.observe('click', this.onDestroyMessage.bindAsEventListener(this, link));
    }.bind(this));        
  },
  
  onDestroyMessage: function(event, link) {     
    event.stop();
    if(confirm('Are you sure?')) {      
      this.loadPage(link.getAttribute('href'), {
        method: 'delete',
        parameters: {
          authenticity_token: encodeURIComponent(this.authenticity_token),
          page: this.currentPage()
        }
      });
    }
  },
  
  currentPage: function() {
    var e = this.element.down('div.pagination span.current');
    return e ? e.innerHTML : 1;    
  },
  
  onClickPage: function(event) {
    event.stop();
    this.loadPage(event.element().getAttribute('href'));
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
    $('popup-spinner').show();
  },
  
  handlePageLoaded: function() {
    this.initPaginationLinks();
    $('popup-spinner').hide();    
  },

  handleInboxLink: function(event) {
    if (event) event.stop();

    this.deselectAllLinks();

    var unread_link = this.element.down('.button.popup');
    unread_link.up().addClassName('active');
    unread_link.up().up().addClassName('active');

    new Effect.ScrollTo(this.element, {duration: 0.4});

    this.openPopup();
    this.loadPage('/users/' + $('user-id').value + '/messages/unread');
  }
  
});

document.observe('dom:loaded', function() {
  MailBox.instance = new MailBox();

  if (window.location.href.split(/#/)[1] == 'inbox') {
    MailBox.instance.handleInboxLink();
  }
});

