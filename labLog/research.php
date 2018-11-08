<!DOCTYPE html>
<html lang="cs">
<head>
	<title>Research</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="author" content="Tomáš Apeltauer, apelttom@gmail.com">
	<meta name="keywords" content="PhD,research,Apeltauer,Tomáš">
	<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
	<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Montserrat">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
	<link href="css/styles.css" media="screen" rel="stylesheet" type="text/css" />
</head>

<body class="w3-light-grey">

	<?php include ("navigation.php"); ?>

	<!-- Page Content -->
	<div class="w3-padding-large" id="main">

      <!-- Research Goal Section -->
      <div class="w3-content w3-justify w3-text-black w3-padding-64" id="research">
	      <h2 class="w3-text-black">What do I want to achieve?</h2>
	      <hr style="width:200px" class="w3-opacity">
				<p>
					At the beginning of the 21.st century human race is facing <a target="_blank" href="https://youtu.be/QX3M8Ka9vUA">The Third Industrial Revolution</a>. We are gonna build smart self-driving cars, smart homes, smart agriculture and all these things will be full of sensors and controllers. These devices will be combining physical world with software world. Such devices are called cyber-physical systems. They will monitor the environment around us in real time and react on changes by changing their behaviour. We are gonna use such devices (e.g. self-driving cars) for our everyday life hence they have to be as secure as possible. If the whole population should use such cyber-physical systems, it has to be more secure than <a target="_blank" href="https://www.spacex.com/mars">Elon's Musk SpaceX rockets</a>.
				</p>
				<p>
					This is my mission. To make all these new cyber-physical systems (<a target="_blank" href="https://www.tesla.com/en_GB/autopilot?redirect=no">Tesla autopilot car</a>, <a target="_blank" href="https://www.tesla.com/en_GB/solarroof?redirect=no">smart solar roof</a>, <a target="_blank" href="https://www.waterfurnace.com/residential/about-geothermal/how-it-works">geothermal power plants</a>, etc.) as secure and safe as possible.
				</p>
			</div>

			<!-- Goal Achievement Section -->
			<div class="w3-content w3-justify w3-text-black w3-padding-64" id="goal_achievement">
				<h2 class="w3-text-black">How do I want to achieve it?</h2>
				<hr style="width:200px" class="w3-opacity">
				<p>
					So how one can improve safety of such complex systems like smart cars, trains, wind turbines? To answer such question we have to ask another one. How do we build these things? How do we test them and how do we measure their safety? Well it looks like companies nowadays model new components first before actually manufacturing them. It is called <a target="_blank" href="https://www.mathworks.com/help/simulink/gs/example_workflow.png">Model-Based Design</a>. It makes sense, creating model in <a target="_blank" href="https://www.mathworks.com/products/simulink.html">MATLAB/Simulink</a> is easier and cheaper than manufacturing it. For example building new square wheel without the knowledge if it will be actually working is not smart. Now creating a square wheel model in MATLAB/Simulink and simulating it's behaviour instead, that is smart! So we build new things by modeling them first in a digital world and running simulations. If that looks good, we can create a prototype and test it real life. My research is in the area of these models.
				</p>
				<img src="./img/round_wheel.png" style="width:100%">
				<p>
					People make mistakes. When an engineer creates a model of a brand new space rocket in a shape of a carrot, he can make mistakes too. We do not want these mistakes to propagate all the way down to the prototype. In order to avoid this, companies use testing against a set of requirements when validating the model. Such requirements can be of all sorts, for example <b>Requirement n.1</b>: Carrot Space Rocket must never enter the state when there would be 10 g-force, because that is deadly for human beings. Now if we have a model of a Carrot Space Rocket, we can run the simulation of it's launch and observe if it would violate our requirement and kill all crew.
				</p>
				<img src="./img/carrot_space_shuttle.png" style="width:100%">
				<p>
					Run these tests manually is very, very, VERY time-consuming. That is why we have tools to automate them (e.g. <a target="_blank" href="https://sites.google.com/a/asu.edu/s-taliro/s-taliro">S-TaLiRo</a>, <a target="_blank" href="https://openmodelica.org/">Modelica</a>, or <a target="_blank" href="https://ptolemy.berkeley.edu/">Ptolemy</a>). Sadly these tools have it's limitations, since they treat most of the models as black-box. When dealing with models of smart systems (such as <a target="_blank" href="https://en.wikipedia.org/wiki/Anti-lock_braking_system">Anti-lock braking system</a> in cars) these tools cannot effectively verify that model meets the requirements. This combination of discrete logic and continuous behaviour of mechanical parts makes it very hard. I am working on a creation of new algorithms which would deal with this situation.
				</p>
			</div>

	<?php include ("footer.php"); ?>

	<!-- END PAGE CONTENT -->
	</div>
</body>
</html>
