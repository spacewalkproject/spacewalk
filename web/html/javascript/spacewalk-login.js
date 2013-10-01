$(document).on("ready", function(){
	$("aside").remove();
	$(document).ready(function() {
	    var me = $("section");
	    var newMe = $("<div class='login-page'>");
	    newMe.html(me.html());
	    me.replaceWith(newMe);
	});
});