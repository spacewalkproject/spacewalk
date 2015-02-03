var latestScrollPos = {x:0, y:0};

function saveScroll() {
    data = getScrollXY();
    latestScrollPos.x = data.x;
    latestScrollPos.y = data.y;
}

// Borrowed from this site:
// http://www.howtocreate.co.uk/tutorials/javascript/browserwindow
function getScrollXY() {
  var scrOfX = 0, scrOfY = 0;
  if( typeof( window.pageYOffset ) == 'number' ) {
    //Netscape compliant
    scrOfY = window.pageYOffset;
    scrOfX = window.pageXOffset;
  } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
    //DOM compliant
    scrOfY = document.body.scrollTop;
    scrOfX = document.body.scrollLeft;
  } else if( document.documentElement && 
          ( document.documentElement.scrollLeft || 
            document.documentElement.scrollTop ) ) {
    //IE6 standards compliant mode
    scrOfY = document.documentElement.scrollTop;
    scrOfX = document.documentElement.scrollLeft;
  }
  var r = {x:scrOfX, y:scrOfY};
  return r;
}

function restoreScroll() {
    var x = document.getElementById('scrollPosX').getAttribute("value");
    var y = document.getElementById('scrollPosY').getAttribute("value");
    window.scrollBy(x,y)
}

function refreshURL() {
    document.getElementById('scrollPosX').setAttribute("value", latestScrollPos.x);
    document.getElementById('scrollPosY').setAttribute("value", latestScrollPos.y);
    document.getElementById('saveScrollPosition').submit();
}

jQuery(window).load(function() {
	restoreScroll();
	jQuery(window).scroll(saveScroll);
	setTimeout(refreshURL, 15000);
});

