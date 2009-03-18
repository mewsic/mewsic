<!-- Moved into app/views/users/_coolest.html.erb -->

<!-- Width value are determined by padding the span votes -_-, layout is a little messy
	no way for cross browsing. Max value is 105px, Min value 16px  -->
<ul class="people_chart">
	<h2>Coolest People</h2>
	<li>
		<div class="votes_chart">
			<div class="avatar fleft">
				<a href="">
				<img src="images/temp/avatar_alvarez.jpg" width="40" height="40" />					
				</a>
			</div>
				<span class="chart_value alright" style="padding-left: 105px;">481 votes</span>
			<a href="" class="song_author block"><strong>Alvarez de la Fonzeca</strong></a>
			
			<? include('_stars.php') ?>
			
		</div>					
	</li>
	<li>
		<div class="votes_chart">
			<div class="avatar fleft">
				<a href="">
				<img src="images/temp/avatar_enzo.jpg" width="40" height="40" />					
				</a>
			</div>
				<span class="chart_value alright" style="padding-left: 80px;">151 votes</span>
			<a href="" class="song_author block"><strong>ENZO</strong></a>

			<? include('_stars.php') ?>

		</div>					
	</li>
	<li>
		<div class="votes_chart">
			<div class="avatar fleft">
				<a href="">
				<img src="images/temp/avatar_fabio.jpg" width="40" height="40" />					
				</a>
			</div>
				<span class="chart_value alright" style="padding-left: 30px;">98 votes</span>
			<a href="" class="song_author block"><strong>Babongo</strong></a>

			<? include('_stars.php') ?>

		</div>					
	</li>
	<li>
		<div class="votes_chart">
			<div class="avatar fleft">
				<a href="">
				<img src="images/temp/avatar_ndstr.jpg" width="40" height="40" />					
				</a>
			</div>
					<span class="chart_value alright" style="padding-left: 16px;">23 votes</span>
			<a href="" class="song_author block"><strong>NDSTR</strong></a>

			<? include('_stars.php') ?>

		</div>					
	</li>
</ul>
