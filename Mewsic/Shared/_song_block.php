<!-- Moved into app/views/shared/_song_block.html.erb -->

<div class="song_block fleft">
	<div class="avatar fleft">
		<img src="images/user_thumb.jpg" width="40" height="40" />					
	</div>
	<div class="tracks_count fleft">
		<h3><?=rand(2,23);?></h3>
		Instr.s
	</div>
	<div class="song_details fleft">
		<a href="" class="song_title">Lorem ipsum dolor sit amet</a><br />
		<a href="" class="song_author"><strong>Gerardo Palla</strong></a><br />

		<? include('_stars.php') ?>
	</div>
	
	<ul class="song_controls fright">
		<li class="mixable_link"><a href="">(Mixable songs (23</a></li><!-- WTF? -->
		<!-- con apposita icona l'effetto transfer potrebbe essere carino -->
		<li><a href="#added<?=rand(1,100);?>" id="addthis" class="control_add">ADD</a></li>
		<li><a href="" class="control_mix">MIX</a></li>
		<li><a href="" class="control_play">PLAY</a></li>
	</ul>
</div>
