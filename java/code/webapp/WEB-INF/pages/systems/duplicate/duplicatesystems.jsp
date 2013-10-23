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
<rhn:toolbar base="h1" icon="icon-desktop" imgAlt="system.common.systemAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-system-list-ood">
  <bean:message key="duplicates.jsp.header"/>
</rhn:toolbar>

<c:choose>
	<c:when test="${not empty requestScope.hostname}">
		<c:set var="filtermessage" value="row.hostname"/>
		<c:set var="key_type" value="hostname"/>
	</c:when>
	<c:when test="${not empty requestScope.ip}">
		<c:set var="filtermessage" value="row.ip"/>
		<c:set var="key_type" value="ip"/>
	</c:when>
	<c:when test="${not empty requestScope.ipv6}">
		<c:set var="filtermessage" value="row.ipv6"/>
		<c:set var="key_type" value="ipv6"/>
	</c:when>
	<c:otherwise>
		<c:set var="filtermessage" value="row.macaddress"/>
		<c:set var="key_type" value="macaddress"/>
	</c:otherwise>
</c:choose>


<rl:listset name="DupesListSet" legend="system">

        <rhn:csrf />

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
<br/>
<rl:list
	emptykey="nosystems.message"
	parentiselement = "false"
	searchchild="false"
	>

	<rl:rowrenderer name="DuplicateSystemsRowRenderer" />
	<rl:decorator name="SelectableDecorator"/>
	<rl:decorator name="ExpansionDecorator"/>
	<rl:decorator name="ExtraButtonDecorator"/>
	<c:choose>
		<c:when test = "${rl:expandable(current)}">
		<rl:selectablecolumn value="${current.key}"/>
		</c:when>
		<c:otherwise>
		<rl:selectablecolumn value="${current.id}"/>
		
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
					<c:out value="${current.name}" escapeXml="true" />
				</c:otherwise>
			</c:choose>
	    </rl:non-expandable>
	</rl:column>
	<rl:column headerkey="systemlist.jsp.last_checked_in">
		<rl:expandable><a href="/rhn/systems/DuplicateSystemsCompare.do?key=${current.key}&key_type=${key_type}"><bean:message key="Compare Systems"/></a></rl:expandable>
		<rl:non-expandable>${current.lastCheckinString}</rl:non-expandable>						
	</rl:column>

</rl:list>

  <div class="text-right">
    <html:submit styleClass="btn btn-default" property="dispatch">
       <bean:message key="Delete Selected"/>
    </html:submit>

  </div>
<rhn:submitted/>

</rl:listset>

</body>
</html>
