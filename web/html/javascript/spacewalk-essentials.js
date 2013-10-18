$(document).on("ready", function(){

  /* Menu in the left column - actions to hide submenu and create animation when a 
  menu only has submenues and doesnt have a URL */
  $("#sidenav ul>ul").hide();

  $("#sidenav li.active").each(function() {
    $(this).next("ul").show();
  });

  /* Systems Selected Toolbar - actions to hide the toolbar when th Clear button is pressed or when 
  no system is selected */

  $("#clear-btn").click(hidesystemtool);

  function hidesystemtool(){
    $(".spacewalk-bar").animate({
      "right": "-=50px",
      "opacity": "0"},
      300, function() {
      /* after animation is complete we hide the element */
      $(this).hide();
    });
  }
  // See if there is a system already selected as soon as the page loads
  updateSsmToolbarOpacity();
});
/* Getting the screen size to create a fixed padding-bottom in the Section tag to make both columns the same size */
// On window load
$(window).load(function () {
  columnHeight();
});

// On window resize
$(window).resize( function () {
  $(".spacewalk-main-column-layout section").css("padding-bottom", "");
  columnHeight();
});

// Make columns 100% in height
function columnHeight() {
  //Only if the screen size is higher than the max-width set up in the Variables.less under the definition @screen-md: 
  //PLEASE: update this if you change the content of @screen-md
  if ($(document).width()>992) {
    var sectionHeight = $(".spacewalk-main-column-layout section").outerHeight();
  	var heightDoc = $(document).height();
    // Column heights should equal the document height minus the header height and footer height
    var newHeight = heightDoc - 160 - sectionHeight + "px";
    $(".spacewalk-main-column-layout section").css("padding-bottom", newHeight);
  };
};

// Render page fragments loaded via DWR
function makeAjaxCallback(divId, debug) {
  cb = function(text) {
    if (debug) {
      alert(text);
    }
    $('#' + divId).html(text);
    $('#' + divId).fadeIn();
    columnHeight();
  };
  return cb;
}

