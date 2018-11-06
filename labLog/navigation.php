<!-- Identifying page name of current page (different for each page) -->
<?php $pagename = basename($_SERVER['PHP_SELF']); ?>

<!-- Icon Bar (Sidebar - hidden on small screens) -->
<nav class="w3-sidebar w3-bar-block w3-small w3-hide-small w3-center">
  <!-- Avatar image in top left corner -->
  <a href="index.php"><img src="img/template/avatar_smoke.png" style="width:100%"></a>
  <a href="index.php" class="<?php if ($pagename == 'index.php') {echo 'w3-light-grey';} else {echo 'w3-hover-light-grey';} ?> w3-bar-item w3-button w3-padding-large">
    <i class="fa fa-home w3-xxlarge"></i>
    <p>HOME</p>
  </a>
  <a href="research.php" class="<?php if ($pagename == 'research.php') {echo 'w3-light-grey';} else {echo 'w3-hover-light-grey';} ?> w3-bar-item w3-button w3-padding-large">
    <i class="fa fa-university w3-xxlarge"></i>
    <p>RESEARCH</p>
  </a>
</nav>

<!-- Navbar on small screens (Hidden on medium and large screens) -->
<div class="w3-top w3-hide-large w3-hide-medium" id="myNavbar">
  <div class="w3-bar w3-grey w3-opacity w3-hover-opacity-off w3-center w3-small">
    <a href="index.php" class="w3-dark-grey w3-bar-item w3-button" style="width:50% !important">HOME</a>
    <a href="research.php"  class="w3-bar-item w3-button" style="width:50% !important">RESEARCH</a>
  </div>
</div>
