<!-- Moved into app/views/tracks/_search.html.erb -->

<div id="instr_search_box">
		<div class="browse_pane pane_heading fright">
			<h2>Instruments on Mewsic</h2>
			<span class="subtitle block">Browse and discover blah blah</span>
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
				<ul class="maingenre_type alleft">
					<li class="current"><a href="">All</a></li>
					<li><a href="">Rock</a></li>
					<li><a href="">Indie</a></li>
					<li><a href="">Electronic</a></li>
					<li><a href="">Pop</a></li>
					<li><a href="">Metal</a></li>																									
					<li><a href="">Hip-Hop</a></li>																									
					<li><a href="">Jazz</a></li>																									
					<li><a href="">Classical</a></li>																									
					<li><a href="">Country</a></li>																																													
				</ul>
				<div id="instr_show" class="fleft">
					<? include('_instr_flag.php'); instr_show(rand(4,25)) ?>
				</div>
			</div>
		</div>
</div>
<div class="clear"> </div>
