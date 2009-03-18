<!-- Moved into app/views/tracks/index.html.erb -->
<? include('__heading.php') ?>

<!-- CONTENT -->
<div id="content">

	<!-- LEFTCOL -->
	<div class="leftCol fleft">
		<div class="leftColWrapper">

			<!-- EXPL BANNER -->
				<div id="expl_banner">
					<span id="expl_hide" class="fright">hide</span>
					<span class="expl_band fleft"> </span>
					<h1>Create MewBands with people all the world.</h1>
					<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean semper, ipsum<br />
					eget dapibus sagittis, nunc nunc feugiat neque, vel blandit turpis<br />
					tellus eu leo. Fusce semper.</p>
					<ul class="expl_links fright">
						<li><a href=""><strong>Create</strong></a></li>
						<li><a href=""><strong>Learn More</strong></a></li>
					</ul>
				</div>
			<!-- END EXPL BANNER -->


			<?  ?>
			<? include('_instruments_search.php') ?>
			<? include('_instruments_newest.php') ?>			

		</div>
	</div>
	<!-- END LEFTCOL -->	

	<!-- RIGHTCOL -->	
	<div class="rightCol fright">

			<?  ?>
			<? include('_didyouknow.php') ?>	

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

<? $partial = "_band_pick_footer.php"; ?>
<? include('__footer.php'); ?>
