<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
 miscUrl="${url}"
 miscAcl="user_role(org_admin)"
 miscText="${text}"
 miscImg="${img}"
 miscAlt="${text}"
imgAlt="users.jsp.imgAlt">
<bean:message key="sys_entitlements.header"/>
</rhn:toolbar>

<bean:message key="sys_entitlements.description"/>
<p/>

<rl:listset name="entitlementSet">
    <rl:list dataset="pageList"
             width="100%"
             name="pageList"
             styleclass="list"
             emptykey="sys_entitlements.noentitlements">

        <rl:column bound="false"
            sortable="false"
            headerkey="sys_entitlements.ent_name"
            styleclass="first-column">
            <a href="/rhn/admin/multiorg/EntitlementDetails.do?label=${current.label}">${current.name}</a>
        </rl:column>
        <rl:column bound="false"
            sortable="false"
            headerkey="sys_entitlements.total">
            ${current.total}
        </rl:column>
        <rl:column bound="false"
            sortable="false"
            headerkey="sys_entitlements.available">
            ${current.available}
        </rl:column>
        <c:if test="${orgCount > 1}">
        <rl:column bound="false"
            sortable="false"
            headertext="${rhn:localize('sys_entitlements.usage')} <br/> (${rhn:localize('Used/Allotted')})**"
            >
            <bean:message key="sys_entitlements.usagedata" arg0="${current.used}" arg1="${current.allocated}" arg2="${current.ratio}"/>
        </rl:column>
        </c:if>

    </rl:list>
</rl:listset>
<p/>
<rhn:tooltip typeKey="Tip">*-<bean:message key = "sys_entitlements.tip"/></rhn:tooltip>
<rhn:tooltip typeKey="Tip">**-<bean:message key = "Used/Allotted.tip"/></rhn:tooltip>
</body>
</html>

