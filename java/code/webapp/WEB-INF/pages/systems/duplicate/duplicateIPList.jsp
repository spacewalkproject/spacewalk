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
<rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="system.common.systemAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-system-list-ood">
  <bean:message key="duplicate-ip.jsp.header"/>
</rhn:toolbar>
<p>
<bean:message key="duplicate-ip.jsp.message"/>
</p>
<rl:listset name="DupesListSet" legend="system">
<rl:list 
	emptykey="nosystems.message"
	filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter"
	>
    <rl:decorator name="ElaborationDecorator"/>
    <c:if test = "${empty noSystemIcons}">
  	    <rl:decorator name="SystemIconDecorator"/>
	    <rl:decorator name="SystemHealthIconDecorator"/>
    </c:if>
	<rl:decorator name="PageSizeDecorator"/>
 	<rl:decorator name="SelectableDecorator"/>
 	<rl:selectablecolumn value="${current.id}"
 						selected="${current.selected}"
 						disabled="${not current.selectable}"
 						styleclass="first-column"/>

	<!-- Name Column -->
	<rl:column sortable="true" 
			   bound="false"
	           headerkey="systemlist.jsp.system" 
	           sortattr="name" 
	           defaultsort="asc"
	           styleclass="${namestyle}">
		<%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>
	</rl:column>
	
	
	<rl:column sortable="false"
			attr="lastCheckin"
			bound="true"
			styleclass="last-column"
		   headerkey="systemlist.jsp.last_checked_in"/>

</rl:list>

<rl:csv dataset="pageList"
        name="systemList"
        exportColumns="name,id,securityErrata,bugErrata,enhancementErrata,outdatedPackages,lastCheckin,entitlement"/>

<rhn:submitted/>

</rl:listset>

</body>
</html>
