<script type="text/javascript" charset="utf-8">
	$(document).ready(function() {
		$('.dataTable').dataTable( {
			"sPaginationType": "full_numbers",
			"bLengthChange": true,
			"bFilter": true,
			"bSort": false,
			"bInfo": false,
			"bAutoWidth": false,
			
			"oLanguage": {
						"sUrl": "javascripts/dataTables_EN.txt"
					},
			"aoData": [ 
						/* TitleAuthor */ null,
						/* Buttons */ { "bSearchable": false }
					]					
			} );
		} );
</script>
<!-- TODO: You can add additional types of pagination control by extending the $.fn.dataTableExt.oPagination object -->

<div id="playlist_container">
<h2>Playlist</h2>

<div id="playlist_tabs">
	<ul>
		<li><a href="#playlist-songs">(23) Songs</a></li>
		<li><a href="#playlist-instr">(42) Instruments</a></li>
	</ul>

	<div id="playlist-songs">
	<table cellpadding="0" cellspacing="0" border="0" class="display dataTable" id="playlist">
		<thead>
			<tr>
				<th>TitleAuthor</th>
				<th>Buttons</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>
					<a href="" class="song_title">Love my Girl</a><br />
					<a href="" class="song_author">Banana</a>
				</td>
				<td>
					<ul class="song_controls fright">
						<li><a href="" class="control_mix">MIX</a></li>
						<li><a href="" class="control_play">PLAY</a></li>
					</ul>					
				</td>
			</tr>
			<tr>
				<td>
					<a href="" class="song_title">E' morto per noi</a><br />
					<a href="" class="song_author">Gesu Cristo</a>
				</td>
				<td>
					<ul class="song_controls fright">
						<li><a href="" class="control_mix">MIX</a></li>
						<li><a href="" class="control_play">PLAY</a></li>
					</ul>					
				</td>
			</tr>
			<tr>
				<td>
					<a href="" class="song_title">Era una puttana</a><br />
					<a href="" class="song_author">Madonna</a>
				</td>
				<td>
					<ul class="song_controls fright">
						<li><a href="" class="control_mix">MIX</a></li>
						<li><a href="" class="control_play">PLAY</a></li>
					</ul>					
				</td>
			</tr>
			</tbody>
		</table>
		</div>
		
		<div id="playlist-instr">
		<table cellpadding="0" cellspacing="0" border="0" class="display dataTable"  id="playlist">
			<thead>
				<tr>
					<th>TitleAuthor</th>
					<th>Buttons</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>
						<a href="" class="song_title">Budello al vento</a><br />
						<a href="" class="song_author">Sempre Cristo</a>
					</td>
					<td>
						<ul class="song_controls fright">
							<li><a href="" class="control_mix">MIX</a></li>
							<li><a href="" class="control_play">PLAY</a></li>
						</ul>					
					</td>
				</tr>
				<tr>
					<td>
						<a href="" class="song_title">A volte sguelfa</a><br />
						<a href="" class="song_author">Madonna</a>
					</td>
					<td>
						<ul class="song_controls fright">
							<li><a href="" class="control_mix">MIX</a></li>
							<li><a href="" class="control_play">PLAY</a></li>
						</ul>					
					</td>
				</tr>
				<tr>
					<td>
						<a href="" class="song_title">Ratzi era gay</a><br />
						<a href="" class="song_author">Papa</a>
					</td>
					<td>
						<ul class="song_controls fright">
							<li><a href="" class="control_mix">MIX</a></li>
							<li><a href="" class="control_play">PLAY</a></li>
						</ul>					
					</td>
				</tr>
				</tbody>
			</table>
			</div>
	</div>				
</div>