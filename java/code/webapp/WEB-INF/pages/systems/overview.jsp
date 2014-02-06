<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" icon="header-system" imgAlt="overview.jsp.alt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-overview">
  <bean:message key="overview.jsp.header"/>
</rhn:toolbar>

<rl:listset name="systemListSet" legend="system">

    <rhn:csrf />
    <rhn:submitted />
	<c:if test="${not groups}">
    <a href="/rhn/systems/Overview.do?showgroups=true"> <div class="btn btn-default spacewalk-btn-margin-vertical"> <rhn:icon type="header-system-groups" /> <bean:message key="overview.jsp.systems"/> </div> </a>
	      <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
	</c:if>

	<c:if test="${groups}">
	  <a href="/rhn/systems/Overview.do?showgroups=false"> <div class="btn btn-default spacewalk-btn-margin-vertical"> <rhn:icon type="header-system" /> <bean:message key="overview.jsp.groups"/> </div> </a>
	    <%@ include file="/WEB-INF/pages/common/fragments/systems/group_listdisplay.jspf" %>
	</c:if>
</rl:listset>

</body>
</html>

