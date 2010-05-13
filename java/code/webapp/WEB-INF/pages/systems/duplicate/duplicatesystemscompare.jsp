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

<h2><bean:message key="duplicate.compare.jsp.header"/></h2>
<rl:listset name="DupesCompareSet" legend="system">
		<p><bean:message key="duplicate.compares.jsp.message" arg0="${requestScope.maxLimit}"/>.</p>
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
<c:choose> <c:when test="${requestScope.systems.size > 0}">
<table cellpadding="0" cellspacing="0" class="list">
	<thead><tr> 
	<th> Property</th>
	<c:forEach items="${requestScope.systems.servers}" var="current">
  		<th><%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %></th>
	</c:forEach>
	</tr></thead>
	<tbody>
	<tr class="list-row-even" >
		<td><%-- Empty --%></td>
		<c:forEach items="${requestScope.systems.systemIds}" var="current">
	  		<td><input type="submit" name="btn${current.value}" value="${rhn:localize('Delete System Profile')}"/></td>
		</c:forEach>
	</tr>
	<tr>
		<th colspan="${requestScope.systems.size + 1}"><bean:message key="System Identity Properties"/> <a href=""><bean:message key="Click Here To Hide"/> </a></th>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="systemlist.jsp.last_checked_in"/></td>
		<c:forEach items="${requestScope.systems.lastCheckinDates}" var="current">
	  		<td>${current}</td>
		</c:forEach>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="row.macaddress"/></td>
		<c:set var ="items_list" value="${requestScope.systems.macAddresses}"/>
		<c:set var ="href" value=""/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>		
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="row.ip"/></td>
		<c:set var ="items_list" value="${requestScope.systems.ipAddresses}"/>
		<c:set var ="href" value=""/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="System Groups"/></td>
		<c:set var ="items_list" value="${requestScope.systems.systemGroups}"/>
		<c:set var ="href" value="/network/systems/groups/details.pxt?sgid="/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
	</tr>
	<tr>
		<th colspan="${requestScope.systems.size + 1}"><bean:message key="Extended System Identity Properties"/> <a href=""><bean:message key="Click Here To Hide"/> </a></th>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="Registration Date"/></td>
		<c:set var ="items_list" value="${requestScope.systems.registrationDates}"/>
		<c:set var ="href" value=""/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list.jspf" %>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="System ID"/></td>
		<c:set var ="items_list" value="${requestScope.systems.systemIds}"/>
		<c:set var ="href" value=""/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list.jspf" %>
	</tr>
	
	<tr class="list-row-even" >
		<td><bean:message key="Activation Keys"/></td>
		<c:set var ="items_list" value="${requestScope.systems.activationKeys}"/>
		<c:set var ="href" value="/rhn/activationkeys/Edit.do?tid="/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
	</tr>
	<tr>
		<th colspan="${requestScope.systems.size + 1}"><bean:message key="System Content And Monitoring"/> <a href=""><bean:message key="Click Here To Hide"/> </a></th>
	</tr>

	<tr class="list-row-even"> 
		<td><bean:message key="kickstart.channel.label.jsp"/></td>
		<c:set var ="items_list" value="${requestScope.systems.baseChannels}"/>
		<c:set var ="href" value="/rhn/channels/ChannelDetail.do?cid="/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list.jspf" %>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="Child Software Channels"/></td>
		<c:set var ="items_list" value="${requestScope.systems.childChannels}"/>
		<c:set var ="href" value="/rhn/channels/ChannelDetail.do?cid="/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="org.config.channels.jsp"/></td>
		<c:set var ="items_list" value="${requestScope.systems.childChannels}"/>
		<c:set var ="href" value="/rhn/configuration/ChannelOverview.do?ccid="/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="Monitoring Probes"/></td>
		<c:set var ="items_list" value="${requestScope.systems.monitoringProbes}"/>
		<c:set var ="href" value=""/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
	</tr>
	<tr>
		<th colspan="${requestScope.systems.size + 1}"><bean:message key="softwareEntitlementDetails.header.entitlementUsage"/> <a href=""><bean:message key="Click Here To Hide"/> </a></th>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="System Entitlements"/></td>
		<c:set var ="items_list" value="${requestScope.systems.systemEntitlements}"/>
		<c:set var ="href" value=""/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
	</tr>
	<tr class="list-row-even" >
		<td><bean:message key="Software Entitlements"/></td>
		<c:set var ="items_list" value="${requestScope.systems.softwareEntitlements}"/>
		<c:set var ="href" value=""/>
		<%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
	</tr>
	</tbody>	
</table>
</c:when>
<c:otherwise><p><bean:message key = "nosystems.message"/></p></c:otherwise>
</c:choose>
</rl:listset>


</body>
</html>
