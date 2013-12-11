<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<c:choose>
	<c:when test="${not empty requestScope.selectable}">
		<c:set var="headerkey" value="eligible.flexguest.jsp.header"/>
		<c:set var="messagekey" value="eligible.flexguest.jsp.message"/>
		<c:set var="namestyle" value=""/>
		<c:set var="empty_msg" value="eligible.flexguest.jsp.no-systems"/>
	</c:when>
	<c:otherwise>
		<c:set var="headerkey" value="flexguest.jsp.header"/>
		<c:set var="messagekey" value="flexguest.jsp.message"/>
		<c:set var="namestyle" value="first-column"/>
		<c:set var="empty_msg" value="flexguest.jsp.no-systems"/>
	</c:otherwise>
</c:choose>



<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
    <rhn:toolbar base="h1" icon="header-system">
      <bean:message key="virtualentitlements.toolbar" />
    </rhn:toolbar>


    <rhn:dialogmenu mindepth="0"
                    maxdepth="1"
                    definition="/WEB-INF/nav/virt_entitlements.xml"
                    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer"/>
<h2><bean:message key="${headerkey}"/></h2>
		<p><bean:message key="${messagekey}" arg0="http://kbase.redhat.com/faq/docs/DOC-17424"/>
		</p>

<rl:listset name="FlexSet">

<rhn:csrf />

<input type="hidden" name="selected_family" value="${selected_family}" />

	<br/>
	<select name="channel_family">
		<option value="all"><bean:message key="All"/></option>
		<c:forEach items="${family_list}" var="item">
			<option value="${item.id}"
				<c:if test="${selected_family eq item.idString}"> selected</c:if>
				>  ${item.name}
			</option>
		</c:forEach>
	</select>
	<html:submit styleClass="btn btn-default" property="show">
		<bean:message key="system.errata.show"/>
	</html:submit>
	<br/>

<rl:list
	styleclass="list"
	emptykey="${empty_msg}">
			<rl:decorator name="PageSizeDecorator"/>
	<c:if test="${not empty requestScope.selectable && not empty requestScope.dataset}">
		<rl:decorator name="SelectableDecorator"/>
		<rl:selectablecolumn value="${current.id}"
								selected="${current.selected}"/>
	</c:if>

	<!-- Name Column -->
	<rl:column headerkey="systemlist.jsp.system"
		filterattr="name" filtermessage="${filtermessage}"
		styleclass="${namestyle}"
		sortattr="name"
		defaultsort="asc">

			<c:out value="<a href=\"/rhn/systems/details/Overview.do?sid=${current.id}\">"  escapeXml="false" />
			<c:choose>
				<c:when test="${empty current.name}">
					<bean:message key="sdc.details.overview.unknown"/>
				</c:when>
				<c:otherwise>
					<c:out value="${current.name}" escapeXml="true" />
				</c:otherwise>
			</c:choose>

	</rl:column>

	<rl:column headerkey="Status">
			<c:choose>
				<c:when test="${current.active}">
					<bean:message key="Active"/>
				</c:when>
				<c:otherwise>
					<bean:message key="Inactive"/>
				</c:otherwise>
			</c:choose>

	</rl:column>

	<rl:column headerkey="Registered">
			${current.registeredString}
	</rl:column>

</rl:list>
<rhn:submitted/>

<c:if test="${not empty requestScope.selectable && not empty requestScope.dataset}">
	<div class="text-right">
    <html:submit styleClass="btn btn-default" property="dispatch">
        <bean:message key="Make Flex"/>
    </html:submit>

  </div>
</c:if>

</rl:listset>

</body>
</html>
