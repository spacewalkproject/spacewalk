<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<bean:include id="xmlrpc" page="/XMLRPC" />
<bean:write name="xmlrpc" filter="false" />
</body>
</html>
