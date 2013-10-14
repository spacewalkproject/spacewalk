$(document).on("ready", function(){
	/* Menu in the left column - actions to hide submenu and create animation when a 
	menu only has submenues and doesnt have a URL */
	$("#sidenav ul>ul").hide();

	$("#sidenav li.active").each(function() {
		$(this).next("ul").show(300);
	});
	
	/* Systems Selected Toolbar - actions to hide the toolbar when th Clear button is pressed or when 
	no system is selected */
	$("#clearbtn").click(hidesystemtool);
	function hidesystemtool(){
		$(".spacewalk-bar").animate({
			"right": "-=50px",
			"opacity": "0"},
			300, function() {
			/* after animation is complete we hide the element */
			$(this).hide();
		});
	}
});