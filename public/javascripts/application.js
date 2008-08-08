// When object is available, do function fn.
function when(obj, fn) {
  if (Object.isString(obj)) obj = /^[\w-]+$/.test(obj) ? $(obj) : $(document.body).down(obj);
  if (Object.isArray(obj) && !obj.length) return;
  if (obj) fn(obj);
}
 
var Popup = {
  open: function(url) {
    var options = Object.extend({
      name: 'popup',
      width: 500,
      height: 500,
      resizable: 'yes',
      scrollbars: 'yes'
    }, arguments[1] || {});
    var left = window.innerWidth / 2 - options.width / 2;
    var top  = window.innerHeight / 2 - options.height / 2;
    window.open(url, options.name, 'left=' + left + ',top=' + top + ',width=' + options.width + ',height=' + options.height + ',resizable=' + options.resizable + ',scrollbars=' + options.scrollbars);    
  }
};

function pop(url) {
  var popup = window.open(url,'popup', 'height=100, width=300');
  if (window.focus) {
    popup.focus()
  }
  return false;
}

function reload() {
  //var anchor = /#/.test(window.location.href);
  window.location.href = window.location.href.sub(/[#?].*/, '');
  //if (anchor && Prototype.Browser.WebKit)
  //  window.location.href = window.location.href;
}
