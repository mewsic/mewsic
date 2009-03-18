<!-- Moved to the bottom of app/views/dashboard/index -->
<ul class="footer_right_content fright">
	<h2>Last Songs</h2>
	<span class="subtitle block">Lorem ipsum dolor</span>
	<div class=".w440">
		<? for($i=0;$i<3;$i++){ echo"<li class='border_list'>"; include('_song_block.php'); echo"</li>"; } ?>					
	</div>
</ul>
	
