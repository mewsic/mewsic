<!-- Moved into app/views/tracks/_newest.html.erb -->
<div id="instr_list_box">
		<div class="list_head fright">
			<p class="pick_info block">
				<strong>PICK OF THE WEEK</strong>
			</p>
		</div>
		<div class="clear"> </div>

		<div class="browse_pane pane_content">
			<div class="browse_pane_left fleft">
				<div class="loader"> </div>
				<ul class="instr_type alright">
					<li class="current"><a href="">All</a></li>
					<li><a href="">Cordofoni</a></li>
					<li><a href="">Membranofoni</a></li>
					<li><a href="">Idiofoni</a></li>
					<li><a href="">Aerofoni</a></li>
					<li><a href="">Elettrofoni</a></li>																									
				</ul>
			</div>
			<div class="browse_pane_right fleft">
				<div id="newest_list" class="fleft">
					<? for($i=0;$i<6;$i++){ include('_instrument_block.php'); } ?>
				</div>
			</div>
		</div>
</div>
<div class="clear"> </div>
