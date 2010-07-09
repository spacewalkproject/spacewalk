<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
<body onLoad="selectScope()">
<rhn:toolbar base="h1" img="/img/rhn-icon-system_group.gif"
	           helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-notif">
    <bean:message key="filteredit.jsp.header1" />
  </rhn:toolbar>

<h2><bean:message key="filteredit.jsp.header2"/></h2>

<html:form action="/monitoring/config/notification/FilterEdit" method="POST">
    <%@ include file="filter-form.jspf" %>
</html:form>

</body>
</html>
