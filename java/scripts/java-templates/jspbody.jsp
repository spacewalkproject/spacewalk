<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
<body>

<rhn:toolbar base="h1" icon="header-info">
  <bean:message key="###JSPNAME###.toolbar"/>
</rhn:toolbar>

<h2><bean:message key="###JSPNAME###.header2"/></h2>

<div>
    <!-- FORM OR WHATEVER ELSE GOES HERE -->
</div>

</body>
</html>

