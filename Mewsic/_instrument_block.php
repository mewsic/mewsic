<div class="song_block fleft">
	<div class="avatar fleft">
		<img src="images/temp/avatar_alvarez.jpg" width="40" height="40" />					
	</div>
	<div class="instr_avatar instr_shadow fleft">
		<span class="instr icon_<? echo rand(1,35) ?>"> </span>
	</div>
	<div class="song_details fleft">
		<a href="" class="song_title">Lorem ipsum dolor sit amet</a><br />
		<a href="" class="song_author"><strong>Alvarez de la Fonzeca</strong></a><br />

		<? include('_stars.php') ?>
	</div>
	
	<ul class="song_controls fright">
		<li class="mixable_link"><a href="">(Mixable instruments (42</a></li><!-- WTF? -->
		<li><a href="" class="control_add">ADD</a></li>
		<li><a href="" class="control_mix">MIX</a></li>
		<li><a href="" class="control_play">PLAY</a></li>
	</ul>
</div>
<!-- Remove class .instr_shadow from .instr_avatar on .song_block:hover -->