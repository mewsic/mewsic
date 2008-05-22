document.observe('dom:loaded', function() {
  new PictureSlider('friends-scroller',  { size: 225 });
  new PictureSlider('admirers-scroller',  { size: 225 });  
	$('path').addClassName('mypage');
});
