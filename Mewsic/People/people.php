<!-- moved into app/views/users/index.html.erb -->

<? include('__heading.php') ?>

<!-- CONTENT -->
<div id="content">
	<!-- EXPL BANNER -->

	<!-- END EXPL BANNER -->

	<!-- LEFTCOL -->
	<div class="leftCol fleft">
		<div class="leftColWrapper">
			<? include('_people_pick.php') ?>
			<? include('_most_played_artist.php') ?>
		</div>
	</div>
	<!-- END LEFTCOL -->	

	<!-- RIGHTCOL -->	
	<div class="rightCol fright">

			<? include('_coolest_people.php') ?>
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

<? include('_application.php') ?>

<? $partial = "_most_played_artist_footer.php"; ?>
<? include('__footer.php') ?>
