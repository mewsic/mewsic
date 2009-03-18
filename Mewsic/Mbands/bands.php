<!-- Moved into app/views/mbands/index.html.erb -->
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
					<h1>Create MewBands with people from all the world.</h1>
					<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean semper, ipsum<br />
					eget dapibus sagittis, nunc nunc feugiat neque, vel blandit turpis<br />
					tellus eu leo. Fusce semper.</p>
					<ul class="expl_links fright">
						<li><a href=""><strong>Create</strong></a></li>
						<li><a href=""><strong>Learn More</strong></a></li>
					</ul>
				</div>
			<!-- END EXPL BANNER -->


			<? include('_band_pick.php') ?>
			<? include('_coolest_mband.php')?>

		</div>
	</div>
	<!-- END LEFTCOL -->	

	<!-- RIGHTCOL -->	
	<div class="rightCol fright">

		<h2>M-Bands play</h2>
		<p class="tag_genre">
			<a href="">Acid Jazz/Fusion,</a>  <a href="">Acoustic,</a>  <a href="">Alternative 	Rock,</a>  <a href="">Ambient,</a>  <a href="">Blues,</a>  
			<a href="">British Pop,</a>  <a href="">Classic Rock,</a>  <a href="">Country,</a>  <a href="">Country Rock,</a>  <a href="">Crossover,</a>  <a href="">Dance,</a>  
			<a href="">Disco,</a>  <a href="">Drum & Bass,</a>  <a href="">EBM,</a>  <a 	href="">Electro-Rock,</a>  <a href="">Electronic,</a>  <a href="">Folk Rock,</a>  <a href="">Funk</a>
		</p>
		<ul class="pick_page_anchors">
			<li><a href="" class="anchors">Join an M-Band</a></li>
			<li><a href="" class="anchors">Create your own</a></li>
		</ul>
		<br />

	

			<? include('_mband_newest.php') ?>			
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
