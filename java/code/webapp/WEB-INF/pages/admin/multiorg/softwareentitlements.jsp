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

<rl:listset name="entitlementSet">
    <rl:list dataset="pageList"
             width="100%"
             name="pageList"
             filter="com.redhat.rhn.frontend.action.multiorg.SoftwareEntitlementsFilter"
             styleclass="list"             
             emptykey="softwareentitlements.noentitlements">           
        <rl:column bound="false" 
            sortable="false" 
            headerkey="softwareentitlements.header.entitlement.name" 
            styleclass="first-column"
            >  
            <a href="/rhn/admin/multiorg/SoftwareEntitlementDetails.do?cfid=${current.id}">
                ${current.name}
            </a>                         
        </rl:column>

        <rl:column bound="false" 
            sortable="false" 
            headerkey="softwareentitlements.header.total">
           ${current.total}
        </rl:column>                    

        <rl:column bound="false" 
            sortable="false" 
            headerkey="softwareentitlements.header.available">
           ${current.available}
        </rl:column>
         
        <c:if test="${orgCount > 1}"> 
        <rl:column bound="false" 
            sortable="false" 
            headerkey="softwareentitlements.header.usage" 
            styleclass="last-column">            
          <bean:message key="softwareentitlements.usagedata" arg0="${current.used}" arg1="${current.allocated}" arg2="${current.ratio}"/>          
        </rl:column>                 
        </c:if>             

    </rl:list>
</rl:listset>

<span class="small-text">
    <bean:message key="softwareentitlements.tip"/>
</span>

</body>
</html:html>
