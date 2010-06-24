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
    <bean:message key="softwareentitlements.header"/>
</rhn:toolbar>

<bean:message key="softwareentitlements.description"/>

<p/>

<c:choose>
	<c:when test = "${orgCount > 1}">
		<c:set var = "countstyle" value= ""/>
		<c:set var = "usagestyle" value = "last-column"/>
	</c:when>
	<c:otherwise>
		<c:set var = "countstyle" value= "last-column"/>
		<c:set var = "usagestyle" value = ""/>
	</c:otherwise>
</c:choose>



<rl:listset name="entitlementSet">
    <rl:list alphabarcolumn="name"
             styleclass="list"             
             emptykey="softwareentitlements.noentitlements">
            <rl:decorator name="PageSizeDecorator"/>                        
        <rl:column 
            sortattr="name"
            filterattr="name" 
            headerkey="softwareentitlements.header.entitlement.name" 
            styleclass="first-column"
            >  
            <a href="/rhn/admin/multiorg/SoftwareEntitlementDetails.do?cfid=${current.id}">
                ${current.name}
            </a>                         
        </rl:column>

        <rl:column 
            headertext="${rhn:localize('Regular Counts')} <br/> (${rhn:localize('Available/Total')})*">
            <c:choose>
            	<c:when test="${empty current.total or current.total == 0}">
            		<bean:message key="softwareentitlements.noentitlements"/>
				</c:when>            		
            	<c:otherwise>
          				${current.available} / ${current.total}
            	</c:otherwise>
            </c:choose>            
        </rl:column>                    
         
        <c:if test="${orgCount > 1}"> 
        <rl:column
        	headertext="${rhn:localize('Regular Usage')} <br/> (${rhn:localize('Used/Alloted')})**">
            <c:choose>
            	<c:when test="${empty current.allocated or current.allocated == 0}">
            		<bean:message key="None Allocated"/>
            	</c:when>	
            	<c:otherwise>
            	<bean:message key="softwareentitlements.usagedata" arg0="${current.used}" arg1="${current.allocated}" arg2="${current.ratio}"/>
            	</c:otherwise>            	
            </c:choose>                    
        </rl:column>                 
        </c:if>

        <rl:column 
        	styleclass="${countstyle}"
            headertext="${rhn:localize('Flex Counts')} <br/> (${rhn:localize('Available/Total')})*">
            <c:choose>
            	<c:when test="${empty current.totalFlex or current.totalFlex == 0}">
            		<bean:message key="softwareentitlements.noentitlements"/>
				</c:when>            		
            	<c:otherwise>
          				${current.availableFlex} / ${current.totalFlex}
            	</c:otherwise>
            </c:choose>
        </rl:column>                    
         
        <c:if test="${orgCount > 1}"> 
        <rl:column bound="false" 
			headertext="${rhn:localize('Flex Usage')} <br/> (${rhn:localize('Used/Alloted')})**"
            styleclass="${usagestyle}">
            <c:choose>
            	
            	<c:when test="${empty current.allocatedFlex or current.allocatedFlex == 0}">
            		<bean:message key="None Allocated"/>
            	</c:when>
            	<c:otherwise>
          <bean:message key="softwareentitlements.usagedata" arg0="${current.usedFlex}" arg1="${current.allocatedFlex}" arg2="${current.flexRatio}"/>
            	</c:otherwise>            	
            </c:choose>
        </rl:column>
        </c:if>

    </rl:list>
</rl:listset>

<rhn:tooltip typeKey="Tip">*-<bean:message key = "Available/Total.tip"/></rhn:tooltip>
<rhn:tooltip typeKey="Tip">**-<bean:message key = "Used/Alloted.tip"/></rhn:tooltip>
</body>
</html:html>
