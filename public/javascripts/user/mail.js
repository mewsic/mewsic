var MailBox = Class.create({
  
  initialize: function() {
    this.element = $('user-mail');
    this.authenticity_token = $('authenticity-token').value;
    this.setup();
  },
  
  setup: function() {     
    this.popup = this.element.down('div.popup');
    this.container = this.popup.down('div.container');
    this.element.select('a.button.popup').invoke('observe', 'click', this.handleOpenPopup.bind(this));
    this.popup.down('a.button.close').observe('click', this.handleClosePopup.bind(this));    
  },
  
  updateReceivedCount: function(count) {
    this.element.down('.received.count').update(count);
  },
  
  updateUnreadCount: function(count) {
    this.element.down('.unread.count').update(count);
  },
  
  handleClosePopup: function(event) {
    event.stop();      
    this.closePopup();    
  },
  
  closePopup: function() {
    this.deselectAllLinks();
    this.popup.hide();
    this.container.update('').hide();
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
    this.popup.show();
    this.container.show();
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
  }
  
});

document.observe('dom:loaded', function() {
  MailBox.instance = new MailBox();
});

