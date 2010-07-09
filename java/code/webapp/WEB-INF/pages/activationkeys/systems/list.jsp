<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="systems" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>


<div class="page-summary">
	<h2><img src="/img/rhn-icon-system.gif" alt="${rhn:localize('system.common.systemAlt')}" />
	<bean:message key="Systems"/>
	</h2>
    <p>
    <bean:message key="activation-key.systems.para1"/>
    </p>

<c:set var="pageList" value="${requestScope.all}" />
<rl:listset name="systemsListSet">
	<rl:list dataset="pageList"
         width="100%"
         name="list"
         emptykey="nosystems.message"
         alphabarcolumn="name">
 			<rl:decorator name="PageSizeDecorator"/>

  	   <!--Name Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemlist.jsp.system"
		           sortattr="name" filterattr="name" styleclass="first-column">
		    <c:choose>
		    	<c:when test = "${not empty requestScope.accessMap[current.id]}">
		    		<a href="/rhn/systems/details/Overview.do?sid=${current.id}">${current.name}</a>
		    	</c:when>
		    	<c:otherwise>
		    		${current.name}
		    	</c:otherwise>
		    </c:choose>
		</rl:column>
		<rl:column headerkey="lastCheckin"
		           styleclass="last-column">
		      ${requestScope.dateMap[current.id]}
		</rl:column>
		
		
	</rl:list>
 			
</div>
</rl:listset>
</body>
</html>
