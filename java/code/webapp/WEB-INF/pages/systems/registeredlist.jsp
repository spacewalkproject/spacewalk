<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c-rt" %>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="system.common.systemAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-sstem-list-rregistered">
  <bean:message key="registeredlist.jsp.header"/>
</rhn:toolbar>

<rl:listset name="registeredSystems" legend="system">
  <bean:message key="registeredlist.jsp.view"/>
  <select name="threshold">
   		<c:forEach var="option" items="${options}">
   			<c:choose>
   				<c:when test="${recentlyRegisteredSystemsForm.map.threshold eq option.value}">
   					<option value="${option.value}" selected = "selected">${option.label}</option>
   				</c:when>
   				<c:otherwise>
					<option value="${option.value}">${option.label}</option>
				</c:otherwise>
			</c:choose>		
		</c:forEach>  		
  </select>

  <html:submit>
    <bean:message key="cloneerrata.jsp.view"/>
  </html:submit>
<rhn:submitted/>
<div class="full-width-wrapper" style="clear: both;">
	<rl:list
		dataset="pageList"
		name="systemList"
		decorator="SelectableDecorator"
		emptykey="nosystems.message"
		alphabarcolumn="name"
		filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter"	
		>
		
	 	<rl:decorator name="ElaborationDecorator"/>
   	    <rl:decorator name="SystemIconDecorator"/>
		<rl:decorator name="PageSizeDecorator"/>
		
	 	<rl:selectablecolumn value="${current.id}"
	 						selected="${current.selected}"
	 						disabled="${not current.selectable}"
	 						styleclass="first-column"/>
		<!--Updates Column -->
		<rl:column sortable="false"
				   bound="false"
		           headerkey="systemlist.jsp.status"
		           styleclass="center"
		           headerclass="thin-column">
                      <c:out value="${current.statusDisplay}" escapeXml="false"/>
		</rl:column>
		<!-- Name  Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemlist.jsp.system"
		           sortattr="name" >
			<%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>
		</rl:column>
		<!-- Base Channel Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemlist.jsp.channel"
		           sortattr="channelLabels" >
			<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_list_fragment.jspf" %>
		</rl:column>
		
		<rl:column sortable="true"
				   bound="false"
		           headerkey="registeredlist.jsp.date"
		           sortattr="created"
		           defaultsort="desc">
			  <fmt:formatDate value="${current.created}" type="both" dateStyle="short" timeStyle="long"/>
		</rl:column>
			
		<rl:column sortable="true"
				   bound="false"
		           headerkey="registeredlist.jsp.user"
		           sortattr="nameOfUserWhoRegisteredSystem" >
	      <c:if test="${current.nameOfUserWhoRegisteredSystem != null}">
	        <img src="/img/rhn-listicon-user.gif" alt="<bean:message key="yourrhn.jsp.user.alt" />"  />
	        <c:out value="${current.nameOfUserWhoRegisteredSystem}"/>
	      </c:if>
		</rl:column>
		           		
		<!-- Entitlement Column -->
		<rl:column sortable="false"
				   bound="false"
		           headerkey="systemlist.jsp.entitlement"
		           styleclass="last-column">
                      <c:out value="${current.entitlementLevel}" escapeXml="false"/>
		</rl:column>							 						
	</rl:list>
</rl:listset>
</body>
</html>
