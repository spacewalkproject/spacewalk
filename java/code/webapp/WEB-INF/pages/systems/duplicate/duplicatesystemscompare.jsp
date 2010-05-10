<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
    <script src="/javascript/tree.js" type="text/javascript"></script>
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="system.common.systemAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-system-list-ood">
  <bean:message key="duplicates.jsp.header"/>
</rhn:toolbar>

<c:set var="nosystemicons" value="true"/>

<rl:listset name="DupesCompareSet" legend="system">
		<p><bean:message key="duplicate.compares.jsp.message"/></p>
<br/>
<rl:list 
	emptykey="nosystems.message"
		alphabarcolumn="name"	
		filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter"	
	>
	<rl:decorator name="SelectableDecorator"/>
	<rl:decorator name="PageSizeDecorator"/>
	<rl:selectablecolumn value="${current.id}"
	 						styleclass="first-column"/>

	<!-- Name Column -->
	<rl:column headerkey="systemlist.jsp.system" sortable="true" bound="false" sortattr="name" 
		           defaultsort="asc">
		<%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>		           
	</rl:column>
	<rl:column sortattr="lastCheckinDate"
					attr="lastCheckin"
					bound="true"
				   headerkey="systemlist.jsp.last_checked_in"/>

</rl:list>
  <input type="hidden" name="key" value="${param.key}"/>
  <input type="hidden" name="key_type" value="${param.key_type}"/>

  <div align="right">

    <hr />
    <input type="submit" name="refresh" value="<bean:message key='Refresh Comparison'/>" />
  </div>
<rhn:submitted/>
<br/>
<h2><bean:message key='System Comparison'/></h2>
<c:choose> <c:when test="${not empty requestScope.systems}">
<table cellpadding="0" cellspacing="0" class="list">
<thead><tr> <th> Property</th>
<c:forEach items="${requestScope.systems}" var="current">
  <th><%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %></th>
</c:forEach>
</tr></thead>
</table>
</c:when>
<c:otherwise><p><bean:message key = "nosystems.message"/></p></c:otherwise>
</c:choose>
</rl:listset>


</body>
</html>
