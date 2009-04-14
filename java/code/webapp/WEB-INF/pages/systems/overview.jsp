<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="overview.jsp.alt"
 helpUrl="/rhn/help/reference/en-US/s2-sm-system-overview.jsp">
  <bean:message key="overview.jsp.header"/>
</rhn:toolbar>

<rl:listset name="systemListSet" legend="system">

	<c:if test="${not groups}">
	  <h2><bean:message key="overview.jsp.systems"/></h2>
	      <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
	</c:if>

	<c:if test="${groups}">
	  <h2><bean:message key="overview.jsp.groups"/></h2>
	    <%@ include file="/WEB-INF/pages/common/fragments/systems/group_listdisplay.jspf" %>
	</c:if>
</rl:listset>
	
</body>
</html>

