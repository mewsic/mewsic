var MailBox = Class.create({
  
  initialize: function() {
    this.element = $('user-mail');
    this.user_id = this.element.down('div.user-id').getAttribute('id').match(/^mailbox_(\d+)/)[1];
    this.authenticity_token = this.element.down('div.auth-token').getAttribute('id').match(/^mailbox_(\w+)/)[1];    
    this.setup();
  },
  
  setup: function() {
    this.popup = this.element.down('div.popup');
    this.container = this.popup.down('div.container');
    this.popup.down('a.button.close').observe('click', this.onClosePopup.bind(this));
    this.element.down('a.button.list.received').observe('click', this.onOpenListReceived.bind(this));
    this.element.down('a.button.list.sent').observe('click', this.onOpenListSent.bind(this));
  },
  
  onClosePopup: function(event) {
    event.stop();
    this.popup.hide();
    this.container.update('').hide();
  },
  
  onOpenListReceived: function(event) {
    event.stop();
    event.element().up().addClassName('active');
    event.element().up().up().addClassName('active');
    this.popup.show();
    this.container.show();
    this.loadPage('/users/' + this.user_id + '/messages/');    
  },
  
  onOpenListSent: function(event) {
    event.stop();
    this.popup.show();
    this.container.show();
    this.loadPage('/users/' + this.user_id + '/messages/sent/');    
  },
  
  initPaginationLinks: function() {
    this.popup.select('div.pagination a').invoke('observe', 'click', this.onClickPage.bind(this));
    this.popup.select('a.ajax').invoke('observe', 'click', this.onClickPage.bind(this));
    this.popup.select('a.destroy').invoke('observe', 'click', this.onDestroyMessage.bind(this));
  },
  
  onDestroyMessage: function(event) {
    event.stop();
    if(confirm('Are you sure?')) {
      this.loadPage(event.element().getAttribute('href'), {
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
      onComplete: this.initPaginationLinks.bind(this),
    }, arguments[1] || {});
    new Ajax.Updater(this.container, url, options);
  }
  
});

MailBox.init = function() { MailBox.instance = new MailBox(); }

document.observe('dom:loaded', MailBox.init);

