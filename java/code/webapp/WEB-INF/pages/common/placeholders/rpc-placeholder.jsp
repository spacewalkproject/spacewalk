<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<bean:include id="xmlrpc" page="/XMLRPC" />
<bean:write name="xmlrpc" filter="false" />
</body>
</html>
