<!-- Moved into of app/views/mbands/_footer.html.erb -->

<ul class="footer_right_content mband_pick_footer fright">
	<div class=".w440">
	<h2>M-Band of the Week</h2>
	<div class="snip fleft">

			<a href=""  title="David Bowie" class="fleft">
				<img src="images/temp/coolest_mband.jpg" width="85" height="55" />
			</a>
			<a href="" class="footer_name_link block" title="Sbalndons">
				Sblendons
			</a>
			<p class="tag_genre block">
				<a href="">Acid Jazz,</a><a href="">Acoustic,</a><a href="">Alternative</a>
			</p>
			<a class="item_count block" href="">(109) songs</a>

		<div class="clear"> </div>
		<ul class="mband_flags fright">
			<? flag_list(3); ?>
		</ul>													
	</div>
	<div class="clear"> </div>
	
		<? for($i=0;$i<2;$i++){ echo"<li class='border_list'>"; include('_song_block.php'); echo"</li>"; } ?>
		<li class="mband_more_tag border_list">
			<a href="" class="fright">More songs from this M-band (23)</a>
		</li>
	</div>
</ul>		
