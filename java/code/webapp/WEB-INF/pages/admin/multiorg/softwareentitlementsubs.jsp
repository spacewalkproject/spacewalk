<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">

<head>
<script src="/javascript/multiorg-entitlements.js" type="text/javascript"> </script>
</head>

<body onload="onLoadStuff(4);">
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
    <html:hidden property="orgClicked" value="0"/>

    <rl:list dataset="pageList"
             width="100%"
             name="pageList"
             filter="com.redhat.rhn.frontend.action.multiorg.OrgNameFilter"
             styleclass="list"
             styleId="multiorg-entitlement-listview"             
             alphabarcolumn="orgName"
             emptykey="softwareEntitlementSubs.noOrgsFound">
            
        <rl:column bound="false" 
            sortable="false" 
            headerkey="softwareEntitlementSubs.column.orgName" 
            styleclass="first-column">
            <a href="/rhn/admin/multiorg/OrgDetails.do?oid=${current.org.id}">
                ${current.orgName}
            </a>
        </rl:column>

        <rl:column bound="true" 
            sortable="false" 
            headerkey="softwareEntitlementSubs.column.total" 
            attr="maxMembersDisplay"/>

        <rl:column bound="true" 
            sortable="false" 
            headerkey="softwareEntitlementSubs.column.currentMembers" 
            attr="currentMembers"/>

        <rl:column bound="false" 
            sortable="false" 
            headerkey="softwareEntitlementSubs.column.proposedTotal" 
            styleclass="last-column"
            attr="maxMembers">

            <c:choose>
                <c:when test="${current.maxMembers != null}">
                    <div id="id${current.org.id}">                  
                    <html:text property="newCount_${current.org.id}" size="5" value="${current.maxMembers}"                               
                               onkeydown="return blockEnter(event)" 
                               onclick="rowHash['id${current.org.id}'].toggleVisibility();"/>                                      
                    <html:submit onclick="this.form.orgClicked.value = '${current.org.id}';">                                 
                        <bean:message key="softwareEntitlementSubs.submit"/>
                    </html:submit>                                      
                    <br/>
                    <div class="small-text" id="id${current.org.id}-tooltip">
                        <bean:message key="softwareEntitlementSubs.possibleValues" 
                            arg0="0"
                            arg1="${current.maxMembers + satelliteOrgOverview.freeMembers}"/>
                    </div>
                    </div>
                </c:when>
            </c:choose>

        </rl:column>

    </rl:list>
</rl:listset>
</p>
   <span class="small-text">
      <bean:message key="softwareEntitlementSubs.totaltip"/>
   </span>
<h2><bean:message key="softwareEntitlementSubs.systemWideCounts.header"/></h2>

<table class="details">
    <tr>
        <th>
            <strong><bean:message key="softwareEntitlementSubs.systemWideCounts.total"/>:</strong>
        </th>
        <td>
            ${maxMem}         
            <p/>
             <span class="small-text">
            <bean:message key="softwareEntitlementSubs.systemWideCounts.totaltip"/></em>
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


</body>
</html:html>
