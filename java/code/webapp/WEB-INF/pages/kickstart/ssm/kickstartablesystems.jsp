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
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2><bean:message key="ssm.kickstartable-systems.jsp.title"/></h2>
  <div class="page-summary">
    <p>
    <bean:message key="ssm.kickstartable-systems.jsp.summary"/>
    </p>
  </div>
  
<rl:listset name="systemListSet" legend="system">
	<rl:list 
		emptykey="nosystems.message"
		alphabarcolumn="name"	
		filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter"
		>
   	    <rl:decorator name="ElaborationDecorator"/>
		<rl:decorator name="PageSizeDecorator"/>		
		
		<rl:column sortable="true" 
				   bound="false"
		           headerkey="systemlist.jsp.system" 
		           sortattr="name" 
		           styleclass="first-column"
		           defaultsort="asc">
			<%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>
		</rl:column>
		
		<!-- Base Channel Column -->
		<rl:column sortable="false" 
				   bound="false"
		           headerkey="systemlist.jsp.channel" 
		           styleclass="last-column" >
           <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_list_fragment.jspf" %>
		</rl:column>
	</rl:list>
<h2><bean:message key="ssm.kickstartable-systems.jsp.systems"/></h2>
    <p><bean:message key="ssm.kickstartable-systems.jsp.systems.summary"/></p>

<table class="details">
    <tr>
        <th>
            <bean:message key="ssm.kickstartable-systems.jsp.distribution"/>:
        </th>
        <td>
        
		<input type="radio" name="scheduleManual" value="true" id="manual" 
				onclick="form.distroId.disabled = false;" <c:if test="${empty distros}">disabled="true"</c:if>
			<c:if test="${not empty distros and empty param.scheduleManual or param.scheduleManual =='true' }">checked="checked" </c:if> />
			<strong><bean:message key="ssm.kickstartable-systems.jsp.manual-summary"/>:<strong>
		<br/>
		<c:choose>
			<c:when test="${empty distros}"><strong><bean:message key="ssm.kickstartable-systems.jsp.notrees"/><strong></c:when>
			<c:otherwise>
        <select name="distro" id="distroId" <c:if test="${empty distros or param.scheduleManual == 'false'}">disabled="true"</c:if> />
			<c:forEach var="dist" items="${distros}">
				<option 
				<c:if test="${dist.id == distro}">selected="selected"</c:if> 
				value='${dist.id}'>${dist.label}</option>
			</c:forEach>
		</select>			
			</c:otherwise>
		</c:choose>

        <br />
			<rhn:tooltip>
	            <bean:message key="ssm.kickstartable-systems.jsp.distribution-tooltip"/>
            </rhn:tooltip>
        <br /><br />
		<input type="radio" name="scheduleManual" value="false" id="ipId" 
				onclick="form.distroId.disabled = true;" <c:if test="${empty distros or not empty disableRanges}">disabled="true"</c:if>
			<c:if test="${param.scheduleManual =='false'}">checked="checked" </c:if> />
			<strong><bean:message key="ssm.kickstartable-systems.jsp.ip-summary"/></strong>
		<br/>
			<rhn:tooltip>
	            <bean:message key="ssm.kickstartable-systems.jsp.distribution-tooltip"/>
            </rhn:tooltip>
        </td>
    </tr>
</table>    
<div align="right">
<hr />
<input type="submit" name="dispatch" value="${rhn:localize('ssm.config.subscribe.jsp.continue')}"/>
</div>
<rhn:submitted/>
</div>

</rl:listset>

</body>
</html>