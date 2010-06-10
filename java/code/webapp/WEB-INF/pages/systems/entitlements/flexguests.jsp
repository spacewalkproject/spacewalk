<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<c:choose>
	<c:when test="${not empty requestScope.selectable}">
		<c:set var="headerkey" value="eligible.flexguest.jsp.header"/>
		<c:set var="messagekey" value="eligible.flexguest.jsp.message"/>
		<c:set var="namestyle" value="first-column"/>
	</c:when>
	<c:otherwise>
		<c:set var="headerkey" value="flexguest.jsp.header"/>
		<c:set var="messagekey" value="flexguest.jsp.message"/>
		<c:set var="namestyle" value=""/>
	</c:otherwise>
</c:choose>


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

    <rhn:dialogmenu mindepth="0" 
                    maxdepth="1" 
                    definition="/WEB-INF/nav/virt_entitlements.xml" 
                    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer"/>
		<p><bean:message key="flexguest.jsp.message"/>
		</p>

<rl:list 
	emptykey="nosystems.message"
	parentiselement = "false"
	searchparent="false"
	searchchild="true"
	>

	<rl:rowrenderer name="ExpandableRowRenderer" />
	<rl:decorator name="ExpansionDecorator"/>

	<c:if test="${not empty requestScope.selectable}">
		<rl:decorator name="SelectableDecorator"/>
		<c:choose>
			<c:when test = "${rl:expandable(current)}">
			<rl:selectablecolumn value="${current.id}"
		 						styleclass="first-column"/>
			</c:when>
			<c:otherwise>
			<rl:selectablecolumn value="${current.selectionKey}"
		 						styleclass="first-column"/>
			
			</c:otherwise>
		</c:choose>
	</c:if>


	<!-- Name Column -->
	<rl:column headerkey="systemlist.jsp.system" filterattr="name" filtermessage="${filtermessage}" styleclass="${namestyle}">
	    <rl:expandable rendericon="true"> <a href="/rhn/software/channels/ChannelFamilyTree.do?cfid=${current.id}">${current.name} <em>(${current.entitlementCountMessage})</em>  </a>
	    </rl:expandable>
	    
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

	<rl:column headerkey="Status">
		<rl:expandable></rl:expandable>
		<rl:non-expandable>
			<c:choose>
				<c:when test="${current.active}">
					<bean:message key="Active"/>
				</c:when>
				<c:otherwise>
					<bean:message key="Inactive"/>
				</c:otherwise>
			</c:choose>
			
		</rl:non-expandable>						
	</rl:column>	
	
	<rl:column headerkey="systemlist.jsp.registered"
				styleclass="last-column">
		<rl:expandable></rl:expandable>
		<rl:non-expandable>${current.registeredString}</rl:non-expandable>						
	</rl:column>

</rl:list>
<rhn:submitted/>

<c:if test="${not empty requestScope.selectable}">
	  <div align="right">

    <hr />
    <html:submit property="dispatch">
        <bean:message key="Make Flex"/>
    </html:submit>
      
  </div>
</c:if>


</rl:listset>


</body>
</html>
