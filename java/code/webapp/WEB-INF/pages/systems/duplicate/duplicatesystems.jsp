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

<c:choose>
	<c:when test="${not empty requestScope.hostname}">
		<c:set var="filtermessage" value="row.hostname"/>
	</c:when>
	<c:when test="${not empty requestScope.ip}">
		<c:set var="filtermessage" value="row.ip"/>
	</c:when>
	<c:otherwise>
		<c:set var="filtermessage" value="row.macaddress"/>
	</c:otherwise>
</c:choose>


<rl:listset name="DupesListSet" legend="system">

		<p><bean:message key="duplicate.jsp.message"/><br/>
			<bean:message key="duplicate-ip.jsp.inactive.header"/>
			<select name="inactive_count" onChange="this.form.submit();">
				<option value="4" 		<c:if test="${4 == inactive_count}">selected="selected"</c:if>  >
					<bean:message key="duplicate-ip.jsp.inactive.fourhours"/>
				</option>
				<option value="12"  <c:if test="${12 == inactive_count}">selected="selected"</c:if> >
					<bean:message key="duplicate-ip.jsp.inactive.twelvehours"/>
				</option>
				<option value="24" <c:if test="${24 == inactive_count}">selected="selected"</c:if> >
					<bean:message key="duplicate-ip.jsp.inactive.oneday"/>
				</option>
				<option value="168" <c:if test="${168 == inactive_count}">selected="selected"</c:if> >
					<bean:message key="duplicate-ip.jsp.inactive.oneweek"/>
				</option>
				<option value="720" <c:if test="${720 == inactive_count}">selected="selected"</c:if> >
					<bean:message key="duplicate-ip.jsp.inactive.onemonth"/>
				</option>
				<option value="4320" <c:if test="${4320 == inactive_count}">selected="selected"</c:if> >
					<bean:message key="duplicate-ip.jsp.inactive.sixmonths"/>
				</option>
			</select>
		</p>
<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/duplicate_systems_tabs.xml"
                renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<rl:list 
	emptykey="nosystems.message"
	parentiselement = "false"
	searchchild="false"
	>

	<rl:rowrenderer name="ExpandableRowRenderer" />
	<rl:decorator name="SelectableDecorator"/>
	<rl:decorator name="ExpansionDecorator"/>
	<rl:decorator name="ExtraButtonDecorator"/>
	<c:choose>
		<c:when test = "${rl:expandable(current)}">
		<rl:selectablecolumn value="${current.key}"
	 						styleclass="first-column"/>
		</c:when>
		<c:otherwise>
		<rl:selectablecolumn value="${current.id}"
	 						styleclass="first-column"/>
		
		</c:otherwise>
	</c:choose>


	<!-- Name Column -->
	<rl:column headerkey="systemlist.jsp.system" filterattr="key" filtermessage="${filtermessage}">
	    <rl:expandable rendericon="true">${current.key} <em>(<bean:message key="manysystems.message" arg0="${rl:countChildren(current)}"/>)</em> </rl:expandable>
	    
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
	<rl:column headerkey="systemlist.jsp.last_checked_in"
				styleclass="last-column">
		<rl:non-expandable>
		${current.lastCheckinString}
	  </rl:non-expandable>						
	</rl:column>

</rl:list>
<rhn:submitted/>

</rl:listset>


</body>
</html>
