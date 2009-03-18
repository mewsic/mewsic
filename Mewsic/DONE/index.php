<!-- Moved into app/views/dashboard/index.html.erb -->

	<!-- MISSION TUTORIAL -->
	<div id="mission_tutorial" class="fleft">

	</div>
	<div id="mission_search" class="fleft">
		<h1 class="search_call">
			Look if someone have<br />already played your<br />favourite song!
		</h1>
		<form>
			<input type="text" class="search_call_input fleft" value="Type a Song/Artist">
			<input type="submit" class="search_call_submit fleft" value="Go">
		</form>
	</div>
	<div class="clear"> </div>
	<!-- END MISSION TUTORIAL -->

	<!-- LEFTCOL -->
	<div class="leftCol fleft">
		<div class="leftColWrapper">

			<!-- ARTIST PICK, NO SONG -->
			<div class="pick_wrap">
					<a href="" class="pick_ad block fleft" title="Gerardo Palla" style="background-image: url('images/temp/pick_gerardo.jpg');">
						<p class="pick_info block">
							<strong>PICK OF THE WEEK</strong>
						</p>
					</a>
					<div class="pick_details fright">
						<h1>Gerardo Palla</h1>
						<p class="tag_genre">
							<a href="">Acid Jazz</a><a href="">Acoustic</a><a href="">Alternative</a>
						</p>
						<ul class="pick_page_anchors">
							<li><a href="" class="anchors">PAGE</a></li>
							<li><a href="" class="anchors">VIDEO</a></li>
							<li><a href="" class="anchors">PHOTO</a></li>
							<li><a href="" class="anchors song">SONGS</a></li>																		
						</ul>
						<p class="interview">
							Lorem ipsum dolor sit amet, 
							consectetur adipiscing elit. <a href="">Maecenas</a> nunc pede, facilisis feugiat, posuere a, tempus in, urna. Curabitur sapien. Aliquam elementum mauris. Aenean porttito nec massa mattis rutrum. Maecenas pharetra mi in nunc. Nuarcu sit amet lectus Aliquam elementum maurri del bananas del vinto eterno.
						</p>
					</div>
			</div>
			<!-- END PICK -->

		</div>
	</div>
	<!-- END LEFTCOL -->	

	<!-- RIGHTCOL -->	
	<div class="rightCol fright">

			<? include('_didyouknow.php'); ?>	

	</div>
	<!-- END RIGHTCOL -->	
	
	<div class="clear"> </div>
</div>
<div id="bottom_bar">
	<div class="corner_lb fleft"> </div>
	<div class="bottom_rp fleft"> </div>
	<div class="corner_rb fleft"> </div>
</div>
<!-- END CONTENT -->


<? include('_application.php'); ?>

<? $partial = "_footer_last_songs.php"; ?>
<? include('__footer.php'); ?>
