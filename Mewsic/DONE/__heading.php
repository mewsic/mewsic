<!-- Moved into app/views/layouts/application.html.erb -->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

	<title>MEWSIC</title>

	<link rel="stylesheet" type="text/css" href="stylesheets/type.css" />
	<link rel="stylesheet" type="text/css" href="stylesheets/layout.css" />
	<link rel="stylesheet" type="text/css" href="stylesheets/color.css" />
	<link rel="stylesheet" type="text/css" href="stylesheets/instruments.css" />	
	<link rel="stylesheet" type="text/css" href="stylesheets/appbar.css" />		

 	<script type="text/javascript" src="javascripts/jquery-1.3.2.min.js"></script>

 	<script type="text/javascript" src="javascripts/jquery-ui-1.7.custom.min.js"></script>

 	<script type="text/javascript" src="javascripts/home.js"></script>
	<? include('javascripts/jquery-ui-plugins.js') ?>	

	<link type="text/css" href="stylesheets/themes/base/ui.all.css" rel="stylesheet" />


 	<script type="text/javascript" src="javascripts/jquery.corner.js"></script>

 	<script type="text/javascript" src="javascripts/jquery.MetaData.js"></script>
 	<script type="text/javascript" src="javascripts/jquery.rating.pack.js"></script>
	<link rel="stylesheet" type="text/css" href="stylesheets/jquery.rating.css" />
	
 	<script type="text/javascript" src="javascripts/jquery.dataTables.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="stylesheets/dataTables.css" />		
		
</head>
<body>

<!-- HEADER -->
<div id="header">
	<div class="logo">
		<a href="index.php"><img src="images/header_logo.jpg" /></a>
	</div>
	<ul class="navigation fleft">
		<li><a href="people.php">People</a></li>
		<li><a href="bands.php">Bands</a></li>
		<li><a href="">Songs</a></li>
		<li><a href="instruments.php">Instruments</a></li>
		<li><a href="">Answers</a></li>
	</ul>
	
	<ul class="login fright">
		<li><a href="" class="join_button">JOIN NOW</a></li>
		<li>or connect with <a href="" class="facebook">Facebook</a></li>
		<li><div class="divider"> </div></li>
		<li><a href="" class="login_button">LOGIN</a></li>
	</ul>	
	<div class="clear"> </div>
	<div id="breadcrumb_bar">
		<div class="corner_lt_blue fleft"> </div>
		<div class="bar_rp_blue fleft"> </div>
		<div class="corner_rt_blue fleft"> </div>
	</div>
</div>
<!-- END HEADER -->
