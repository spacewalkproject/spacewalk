<html>
<head>
  <meta http-equiv="cache-control" content="no-cache" />
<style type="text/css">
ul.apidoc {
   list-style-image: url('/img/parent_node.gif');
}
</style>

</head>
<body>
<h1><i class="fa fa-gears"></i>Frequently Asked Questions</h1>
<p />
<ul>
	<dt>What programming languages are supported by the Satellite's api?</dt>
		<dd>Any language that provides an XMLRPC client interface will work with the Satellite's API.  While Perl and Python are two of the most commonly used, an XMLRPC client implementation is available in most every common language. </dd>
	<br />
	<dt>When trying to call a specific function, the error "Fault returned from XML RPC Server, fault code -1: Could not find method METHOD in class..." is given.  What is wrong?</dt>
		<dd>Typically this is seen when either a function name is being called that doesn't exist, the number of parameters for a particular function is incorrect, or the type of a passed parameter is incorrect (Such as an array is expected, but a String is passed).  Check all of these things.</dd>
	<br />
	<dt>Should I call an API method using the naming scheme "methodName" or "method_name"?</dt>
		<dd>Both of these are valid names for the same method, so use whichever you prefer.</dd>
</ul>
</body>
</html>
