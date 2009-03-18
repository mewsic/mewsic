<p class="pick_info block">
	<strong>COOLEST MBANDS</strong>
</p>
<div class="mband_coolest_wrap">

	<div style="margin-top: 8px;" class="fleft">
		<div class="pick_details fleft">
			<? include('_stars.php') ?>
			<h1 class="mband_icon">Sblandons</h1>
			<p class="tag_genre">
				<a href="">Jazz,</a><a href="">Rock,</a><a href="">Alternative</a>
			</p>

			<a href="" class="mband_coolest_ad fleft">
				<img src="images/temp/coolest_mband.jpg" />
			</a>
		</div>
	</div>
	
	<!-- SONG BLOCK -->
	<div class="w454 fright">			

		<div class="mband_members fleft">
			<a href="" class="mband_count block">
				<strong>Sblandons</strong> lineup: (3 users)
			</a>

			<!-- ISTRUMENTS / FLAGS BLOCK -->
				<?  lineup(3); ?>
			<!-- END ISTRUMENTS / FLAGS BLOCK -->				
		</div>

			<? for($i=0;$i<4;$i++){ include('_song_block.php'); } ?>
			<a href="" class="mband_more fright">
				Listen more <strong>Sbelndons</strong> songs (42)
			</a>
	</div>
	<!-- END SONG BLOCK -->
	
	<div class="bottom_tools fleft">
		<div class="fleft margin7">
			<a href="" class="mband_browse"><span>Browse more M-Bands</span></a>
		</div>
		<div class="paging_bg fright">
			<ul class="bullet_paging">
				<li class="bullet"><a href="" class="on"> </a></li>
				<li class="bullet"><a href="" class="off"> </a></li>
				<li class="bullet"><a href="" class="off"> </a></li>								
				<li class="pager"><a href="" class="prev"> </a></li>												
				<li class="pager"><a href="" class="next"> </a></li>																
			</ul>
		</div>
	</div>
</div>