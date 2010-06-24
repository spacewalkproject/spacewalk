<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">

<head>
</head>

<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
	miscUrl="${url}"
	miscAcl="user_role(org_admin)"
	miscText="${text}"
	miscImg="${img}"
	miscAlt="${text}"
	imgAlt="users.jsp.imgAlt">
    ${channelFamily.name}
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="3" definition="/WEB-INF/nav/softwareentitlementtabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />


<h2><bean:message key="softwareEntitlementSubs.viewModifyCounts.header"/></h2>

<bean:message key="softwareEntitlementSubs.viewModifyCounts.description" arg0="${channelFamily.name}"/>
<rl:listset name="orgSet">

    <!-- Reuse the form opened by the list tag -->
    <html:hidden property="submitted" value="true"/>
    <html:hidden property="cfid" value="${channelFamily.id}"/>
    <html:hidden property="orgClicked" value=""/>

    <rl:list
             styleclass="list"
             styleId="multiorg-entitlement-listview"             
             alphabarcolumn="orgName"
             emptykey="softwareEntitlementSubs.noOrgsFound">
            
        <rl:column
            filterattr="orgName" 
            sortattr="orgName"
            headerkey="softwareEntitlementSubs.column.orgName" 
            styleclass="first-column">
            <a href="/rhn/admin/multiorg/OrgDetails.do?oid=${current.org.id}" tabindex="-1">
                ${current.orgName}
            </a>
        </rl:column>
		<c:if test="${not empty requestScope.regularAvailable}">
        <rl:column
        	headertext="${rhn:localize('Regular Usage')} <br/> (${rhn:localize('Used/Alloted')})*"
            >
			<c:choose>
            	<c:when test="${empty current.maxMembers or current.maxMembers == 0}">
            		<bean:message key="None Allocated"/>
            	</c:when>	
            	<c:otherwise>
            	${current.currentMembers}/${current.maxMembers}
            	</c:otherwise>            	
            </c:choose>
		</rl:column>

        <rl:column  
            headerkey="Regular Proposed Total">
	       	<c:choose>
	       		<c:when test = "${current.maxPossibleAllocation == 0}">
	       			<bean:message key="No Entitlements Available"/>
	       		</c:when>
	       		<c:otherwise>
                    <div id="id${current.key}">                  
                    <html:text property="${current.key}" size="10" value="${requestScope.orgs[current.key]}"                               
                               onkeydown="return blockEnter(event)" 
                               />
                    <br/>
                    <div class="small-text" id="id${current.key}-tooltip">
                        <bean:message key="softwareEntitlementSubs.possibleValues" 
                            arg0="0"
                            arg1="${current.maxMembers + satelliteOrgOverview.freeMembers}"/>
                    </div>
                    </div>
	            </c:otherwise>
			</c:choose>
        </rl:column>
        </c:if>
		<c:if test="${not empty requestScope.flexAvailable}">
	        <rl:column
	        	headertext="${rhn:localize('Flex Usage')} <br/> (${rhn:localize('Used/Alloted')})*"
	            >
				<c:choose>
	            	<c:when test="${empty current.maxFlex or current.maxFlex == 0}">
	            		<bean:message key="None Allocated"/>
	            	</c:when>	
	            	<c:otherwise>
	            	${current.currentFlex}/${current.maxFlex}
	            	</c:otherwise>            	
	            </c:choose>
			</rl:column>
			
	        <rl:column  
	            headerkey="Flex Proposed Total">
		       	<c:choose>
		       		<c:when test = "${current.maxPossibleFlexAllocation == 0}">
		       			<bean:message key="No Entitlements Available"/>
		       		</c:when>
		       		<c:otherwise>
	                    <div id="id${current.flexKey}">
	                    <html:text property="${current.flexKey}" size="10" value="${requestScope.orgs[current.flexKey]}"                               
	                               onkeydown="return blockEnter(event)" 
	                               />
	                    <br/>
	                    <div class="small-text" id="id${current.flexKey}-tooltip">
	                        <bean:message key="softwareEntitlementSubs.possibleValues" 
	                            arg0="0"
	                            arg1="${current.maxFlex + satelliteOrgOverview.freeFlex}"/>
	                    </div>
	                    </div>
		            </c:otherwise>
				</c:choose>
	        </rl:column>
		</c:if>

        <rl:column  
            headerkey="emptyspace.jsp" 
            styleclass="last-column"
            >
            <c:if test = "${current.maxPossibleAllocation > 0 || current.maxPossibleFlexAllocation > 0}">
            	<html:submit onclick="this.form.orgClicked.value = '${current.org.id}';">
                        <bean:message key="softwareEntitlementSubs.submit"/>
                    </html:submit>
            </c:if>
            
        </rl:column>

    </rl:list>
</rl:listset>
</p>
<rhn:tooltip key="softwareEntitlementSubs.Used/Alloted"/>
<c:if test="${not empty requestScope.regularAvailable}">
<h2><bean:message key="softwareEntitlementSubs.systemWideCounts.header.regular"/></h2>

<table class="details">
    <tr>
        <th>
            <strong><bean:message key="softwareEntitlementSubs.systemWideCounts.total"/>:</strong>
        </th>
        <td>
            ${maxMem}         
            <p/>
            <rhn:tooltip key="softwareEntitlementSubs.systemWideCounts.totaltip"/>
             </span>
        </td>
    </tr>
    <tr>
        <th>
            <strong><bean:message key="softwareEntitlementSubs.systemWideCounts.entUsage"/>:</strong>
        </th>
        <td>
            <bean:message key="softwareEntitlementSubs.systemWideCounts.entUsageData" 
                  arg0="${curMem}" arg1="${maxMem}" arg2="${entRatio}" /> 
        </td>
    </tr>
    <tr>
        <th>
            <strong><bean:message key="softwareEntitlementSubs.systemWideCounts.orgUsage"/>:</strong>
        </th>
        <td>
        <bean:message key="softwareEntitlementSubs.systemWideCounts.orgUsageData" 
                  arg0="${entitledOrgs}" arg1="${orgCount}" arg2="${orgRatio}" />             
        </td>
    </tr>    
</table>
</c:if>
<c:if test="${not empty requestScope.flexAvailable}">
<h2><bean:message key="softwareEntitlementSubs.systemWideCounts.header.flex"/></h2>

<table class="details">
    <tr>
        <th>
            <strong><bean:message key="softwareEntitlementSubs.systemWideCounts.total"/>:</strong>
        </th>
        <td>
            ${maxFlex}         
            <p/>
            <rhn:tooltip key="softwareEntitlementSubs.systemWideCounts.totaltip"/>
        </td>
    </tr>    
    
	<tr>
        <th>
            <strong><bean:message key="softwareEntitlementSubs.systemWideCounts.entUsage"/>:</strong>
        </th>
        <td>
            <bean:message key="softwareEntitlementSubs.systemWideCounts.entUsageData" 
                  arg0="${curFlex}" arg1="${maxFlex}" arg2="${flexEntRatio}" /> 
        </td>
    </tr>
    <tr>
        <th>
            <strong><bean:message key="softwareEntitlementSubs.systemWideCounts.orgUsage"/>:</strong>
        </th>
        <td>
        <bean:message key="softwareEntitlementSubs.systemWideCounts.orgUsageData" 
                  arg0="${flexEntitledOrgs}" arg1="${orgCount}" arg2="${flexOrgRatio}" />             
        </td>
    </tr>    
</table>

</c:if>
</body>
</html:html>
