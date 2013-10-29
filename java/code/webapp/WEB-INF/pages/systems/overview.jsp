<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" icon="fa-desktop" imgAlt="overview.jsp.alt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-overview">
  <bean:message key="overview.jsp.header"/>
</rhn:toolbar>

<rl:listset name="systemListSet" legend="system">

    <rhn:csrf />
    <rhn:submitted />
	<c:if test="${not groups}">
	  <bean:message key="overview.jsp.systems"/>
	      <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
	</c:if>

	<c:if test="${groups}">
	  <h2><bean:message key="overview.jsp.groups"/></h2>
	    <%@ include file="/WEB-INF/pages/common/fragments/systems/group_listdisplay.jspf" %>
	</c:if>
</rl:listset>
	
</body>
</html>

