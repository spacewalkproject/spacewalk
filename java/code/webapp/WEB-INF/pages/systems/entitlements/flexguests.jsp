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
  <bean:message key="flexguest.jsp.header"/>
</rhn:toolbar>

<rl:listset name="FlexSet">

		<p><bean:message key="flexguest.jsp.message"/>
		</p>
<%-- <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/duplicate_systems_tabs.xml"
                renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" /> --%>
<br/>
<rl:list 
	emptykey="nosystems.message"
	parentiselement = "false"
	searchparent="false"
	searchchild="true"
	>

	<rl:rowrenderer name="ExpandableRowRenderer" />
	<rl:decorator name="ExpansionDecorator"/>

	<!-- Name Column -->
	<rl:column headerkey="systemlist.jsp.system" filterattr="name" filtermessage="${filtermessage}" styleclass="first-column">
	    <rl:expandable rendericon="true">${current.name} <em>(${current.entitlementCountMessage})</em> </rl:expandable>
	    
	    <rl:non-expandable rendericon="true">
			<c:out value="<a href=\"/rhn/systems/details/Overview.do?sid=${current.id}\">"  escapeXml="false" />
			<c:choose>
				<c:when test="${empty current.name}">
					<bean:message key="sdc.details.overview.unknown"/>
				</c:when>
				<c:otherwise>
					<c:out value="${current.name}</a>" escapeXml="false" />
				</c:otherwise>
			</c:choose>
	    </rl:non-expandable>       
	</rl:column>

	<rl:column headerkey="systemlist.jsp.active">
		<rl:expandable></rl:expandable>
		<rl:non-expandable>${current.active}</rl:non-expandable>						
	</rl:column>	
	
	<rl:column headerkey="systemlist.jsp.registered"
				styleclass="last-column">
		<rl:expandable></rl:expandable>
		<rl:non-expandable>${current.registeredString}</rl:non-expandable>						
	</rl:column>

</rl:list>
<rhn:submitted/>

</rl:listset>


</body>
</html>
