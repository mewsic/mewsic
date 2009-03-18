<?
	function lineup($users) {
		for($i=0;$i<$users;$i++) {
?>

<!-- this piece moved into views/mbands/_instrument_flag.html.erb -->

<div class="instr_avatar instr_shadow fleft <? if($i==0){ print first_margin; } ?>">
	<span class="instr icon_<? echo rand(1,35) ?>"> 
		<span class="instr_flag fright">
			<img src="images/icons/flags/<? echo rand(1,53) ?>.gif" width="16" />
		</span>	
	</span>
</div>				
<?

					}
				}
?>




<?
	function flag_list($flags) {
		for($i=0;$i<$flags;$i++) {
?>
<!-- this piece moved into helper flag_icon, located in helpers/mband_helper.rb -->
			<li>
				<img src="images/icons/flags/<? echo rand(1,53) ?>.gif" width="16" />
			</li>
<?

					}
				}
?>





<?
	function instr_show($count) {
		for($i=0;$i<$count;$i++) {
?>
<!-- this piece moved into app/views/tracks/_instrument_big.html.erb -->
<div class="instr_avatar shadow_big  fleft">
	<span class="instr instr_big icon_<? echo rand(41,75) ?>"> 
		<span class="instr_counter">
			<span class="tl">
				<span class="tr">
					<span class="br">
						<span class="bl"><strong><? echo rand(10,999) ?></strong></span>
						<!-- max 5 digit numbers for this layout ;\ -->
					</span>
				</span>
			</span>
		</span>	
	</span>
	<!-- display instruments name with overlay tooltip -->
</div>				
<?

					}
				}
?>
