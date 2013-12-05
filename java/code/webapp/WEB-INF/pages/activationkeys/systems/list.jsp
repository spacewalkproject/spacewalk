<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="name" value="systems" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>


<div class="page-summary">
	<h2><i class="icon-desktop"></i>
	<bean:message key="Systems"/>
	</h2>
    <p>
    <bean:message key="activation-key.systems.para1"/>
    </p>

<c:set var="pageList" value="${requestScope.all}" />
<rl:listset name="systemsListSet">
    <rhn:csrf />
    <rhn:submitted />
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
		           sortattr="name" filterattr="name">
		    <c:choose>
		    	<c:when test = "${not empty requestScope.accessMap[current.id]}">
                    <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
                        <c:out value="${current.name}" escapeXml="true" />
                    </a>
		    	</c:when>
		    	<c:otherwise>
                    <c:out value="${current.name}" escapeXml="true" />
		    	</c:otherwise>
		    </c:choose>
		</rl:column>
		<rl:column headerkey="lastCheckin">
		      ${requestScope.dateMap[current.id]}
		</rl:column>


	</rl:list>

</div>
</rl:listset>
</body>
</html>
