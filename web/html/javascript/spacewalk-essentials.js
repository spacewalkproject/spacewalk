$(document).on("ready", function(){
	/* Menu in the left column - actions to hide submenu and create animation when a 
	menu only has submenues and doesnt have a URL */
	$("#sidenav ul>ul").hide();
	$("#sidenav li").attr('href', '#').on("click", function(){
		$(this).next("ul").slideToggle();
		$(this).toggleClass('active');
		$(this).next("a").toggleClass('active');
	});
	/* Systems Selected Toolbar - actions to hide the toolbar when th Clear button is pressed or when 
	no system is selected */
	$("#clearbtn").click(hidesystemtool);
	function hidesystemtool(){
		$(".spacewalk-bar").animate({
			"right": "=50px",
			"opacity": "0"},
			300, function() {
			/* after animation is complete we hide the element */
			$(this).hide();
		});
	}
});

// taking the screen size and resizing the columns to keep the footer fixed to the bottom
// On page load
$(window).load(columnHeight);

// On window resize
$(window).resize( function () {
    // Clear all forced column heights before recalculating them after window resize
    $("aside").css("height", "");  
    $("section").css("height", "");
    columnHeight();
});

// Make columns 100% in height
function columnHeight() {
	//Only if the screen size is higher than the max-width set up in the Variables.less under the definition @screen-md: 
	//PLEASE: update this if you change the content of @screen-md
	if ($(document).width()>992) {
	    // Column heights should equal the document height minus the header height and footer height
	    var newHeight = $(document).height() - 200 + "px";
	    console.log(newHeight);
	    $("aside").css("height", newHeight);
	    $("section").css("height", newHeight);
    };
}
