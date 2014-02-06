<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
    <head>
    </head>
<body>
<rhn:toolbar base="h1" icon="header-system-groups"
	           helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-notif">
    <bean:message key="filtercreate.jsp.header1" />
  </rhn:toolbar>

<h2><bean:message key="filtercreate.jsp.header2"/></h2>

<html:form action="/monitoring/config/notification/FilterCreate" method="POST">
    <rhn:csrf />
    <rhn:submitted />
    <%@ include file="filter-form.jspf" %>
</html:form>

</body>
</html>
