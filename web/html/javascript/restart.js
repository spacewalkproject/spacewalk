function checkConnection(wait) {
	setTimeout("testConnect()", wait*1000)
}



function testConnect() {

var xmlhttp=false;
/*@cc_on @*/
/*@if (@_jscript_version >= 5)
// JScript gives us Conditional compilation, we can cope with old IE versions.
// and security blocked creation of the objects.
 try {
  xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
 } catch (e) {
  try {
   xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
  } catch (E) {
  }
 }
@end @*/
if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
	try {
		xmlhttp = new XMLHttpRequest();
	} catch (e) {
		xmlhttp=false;
	}
}
if (!xmlhttp && window.createRequest) {
	try {
		xmlhttp = window.createRequest();
	} catch (e) {
		xmlhttp=false;
	}
}

 URL_TO_SEND = "/rhn/admin/config/Restart.do"
 URL_TO_TEST = "/"
 xmlhttp.open("HEAD", URL_TO_TEST,true);
 xmlhttp.onreadystatechange=function() {
  if (xmlhttp.readyState==4) {
	if( xmlhttp.getAllResponseHeaders().length > 0 && xmlhttp.status == 200) {
		window.location = URL_TO_SEND
	}
  }
 }
 xmlhttp.send(null)
 setTimeout("testConnect()", 5000)

}
