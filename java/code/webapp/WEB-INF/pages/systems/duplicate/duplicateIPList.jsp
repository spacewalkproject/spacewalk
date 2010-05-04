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
  <bean:message key="duplicate-ip.jsp.header"/>
</rhn:toolbar>
<p>
<bean:message key="duplicate-ip.jsp.message"/>
</p>

<rl:listset name="DupesListSet" legend="system">
<rl:list 
	emptykey="nosystems.message"
	parentiselement = "false"
	searchchild="false"
	>

	<rl:rowrenderer name="ExpandableRowRenderer" />
	<rl:decorator name="SelectableDecorator"/>
	<rl:decorator name="ExpansionDecorator"/>
	<c:choose>
		<c:when test = "${rl:expandable(current)}">
		<rl:selectablecolumn value="${current.key}"
	 						selected="false"
	 						styleclass="first-column"/>
		</c:when>
		<c:otherwise>
		<rl:selectablecolumn value="${current.id}"
	 						selected="false"
	 						styleclass="first-column"/>
		
		</c:otherwise>
	</c:choose>


	<!-- Name Column -->
	<rl:column headerkey="systemlist.jsp.system" filterattr="key">
	    <rl:expandable rendericon="true">${current.key} <em>(<bean:message key="manysystems.message" arg0="${rl:countChildren(current)}"/>)</em> </rl:expandable>
	    
	    <rl:non-expandable rendericon="true">${current.id}</rl:non-expandable>       
	</rl:column>
	<rl:column headerkey="systemlist.jsp.last_checked_in"
				styleclass="last-column">
		<rl:non-expandable>
		${current.lastCheckinString}
	  </rl:non-expandable>						
	</rl:column>

</rl:list>

<rl:csv exportColumns="key"/>

<rhn:submitted/>

</rl:listset>


</body>
</html>
