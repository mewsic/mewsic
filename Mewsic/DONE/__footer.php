<!-- Moved into app/views/layouts/application.html.erb -->

<div class="clear"> </div>
<!-- FOOTER -->
<div class="top_footer_grad roundTop10">
	<div id="top_footer" class="roundTop10">
			<!-- TOP FOOTER GROUP -->		
			<div class="top_tags">
				<h2>Top Tags</h2>
				<span class="subtitle block">Lorem ipsum dolor</span>
				<p class="tag_genre">
					<a href="">Acid Jazz/Fusion</a>  <a href="">Acoustic</a>  <a href="">Alternative 	Rock</a>  <a href="">Ambient</a>  <a href="">Blues</a>  
					<a href="">British Pop</a>  <a href="">Classic Rock</a>  <a href="">Country</a>  <a href="">Country Rock</a>  <a href="">Crossover</a>  <a href="">Dance</a>  
					<a href="">Disco</a>  <a href="">Drum & Bass</a>  <a href="">EBM</a>  <a 	href="">Electro-Rock</a>  <a href="">Electronic</a>  <a href="">Folk Rock</a>  <a href="">Funk</a>
				</p>
			</div>
			<ul class="best_people">
				<h2>Best Mewsicians</h2>
				<span class="subtitle block">Lorem ipsum dolor</span>
				<li class="user_thumb">
					<img src="images/thumb_loader.gif" width="39" height="39" />
				</li>
				<li class="user_thumb">
					<img src="images/thumb_loader.gif" width="39" height="39" />
				</li>
				<li class="user_thumb">
					<img src="images/thumb_loader.gif" width="39" height="39" />
					<img src="images/user_thumb.jpg" width="40" height="40" class="loaded" />
				</li>
				<li class="user_thumb">
					<img src="images/thumb_loader.gif" width="39" height="39" />
					<img src="images/user_thumb.jpg" width="40" height="40" class="loaded" />
				</li>
			</ul>
			<ul class="new_band">
				<h2>Newest M-Bands</h2>
				<span class="subtitle block">Lorem ipsum dolor</span>
				<li class="user_thumb">
					<img src="images/thumb_loader.gif" width="39" height="39" />
					<img src="images/user_thumb.jpg" width="40" height="40" class="loaded" />
				</li>
				<li class="user_thumb">
					<img src="images/thumb_loader.gif" width="39" height="39" />
					<img src="images/user_thumb.jpg" width="40" height="40" class="loaded" />
				</li>
				<li class="user_thumb">
					<img src="images/thumb_loader.gif" width="39" height="39" />
				</li>
				<li class="user_thumb">
					<img src="images/thumb_loader.gif" width="39" height="39" />
				</li>
			</ul>

			<? 
					include($partial);
			?>
			<div class="clear"> </div>
		<!-- END TOP FOOTER GROUP -->		
		<!-- BOTTOM FOOTER GROUP -->		
		<div class="bottom_footer_grad roundTop10">
			<div id="bottom_footer" class="roundTop10">
				<ul class="fleft">
					<h2>MEWSIC</h2>
					<li><a href="">About</a></li>
					<li><a href="">Vision</a></li>
					<li><a href="">Team</a></li>
					<li><a href="">Blog</a></li>
					<li><a href="">Contact</a></li>															
					<li><a href="">Licensing</a></li>
					<li><a href="">Media Kit</a></li>					
				</ul>
				<ul class="follow_us fleft">
					<h2>FOLLOW US</h2>
					<li><a href="" class="facebook">Facebook</a></li>
					<li><a href="" class="myspace">Myspace</a></li>
					<li><a href="" class="podcast">Podcasts</a></li>
					<li><a href="" class="rss">RSS</a></li>
				</ul>
				<ul class="fleft">
					<h2>GET INVOLVED</h2>
					<li><a href="">Contests</a></li>
					<li><a href="">Call to action</a></li>
					<li><a href="">Promote</a></li>
				</ul>
				<ul class="fleft">
					<h2>SHARE</h2>
				</ul>
				
				<div class="clear"> </div>
				
				<div class="footer_copy">&copy; 2009 All rights reserved&nbsp;&nbsp; 
					<a href="maito:">mail@mewsic.com</a>
				</div>
 			</div>
		</div>
		<!-- END BOTTOM FOOTER GROUP -->
	</div>
</div>
<!-- END FOOTER -->




<script type="text/javascript">
		$('.roundTop10').corner("top 10px");
		$('.roundBottom10').corner("bottom 10px");		
		$('.round10').corner("10px");
		$('.bevelsmall').corner("bevel 1px");
</script>
</body>
</html>
