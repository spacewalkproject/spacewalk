<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<head>

<script type="text/javascript" language="JavaScript">
function setOrgClicked(target) {
    document.forms[0].orgClicked.value=target;
    alert(target);
};
</script>
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
 miscUrl="${url}"
 miscAcl="user_role(org_admin)"
 miscText="${text}"
 miscImg="${img}"
 miscAlt="${text}"
imgAlt="users.jsp.imgAlt">
<c:out value="${entname}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/systemEntitlementOrgs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="entitlementorgs.miniheader"/></h2>
<bean:message key="entitlementorgs.description" arg0="${enthuman}"/>
<p/>

<rl:listset name="entitlementSet">
    <!-- Reuse the form opened by the list tag -->
    <html:hidden property="submitted" value="true"/>
    <html:hidden property="orgClicked" value="0"/>

    <rl:list dataset="pageList"
             width="100%"
             name="pageList"
             filter="com.redhat.rhn.frontend.action.multiorg.SystemEntitlementOrgsFilter"
             styleclass="list"
             emptykey="sys_entitlements.noentorgs">
        <rl:column bound="false"
            sortable="false"
            headerkey="entitlementorgs.orgname"
            styleclass="first-column">

            <a href="/rhn/admin/multiorg/OrgDetails.do?oid=${current.orgid}">${current.name}</a>
        </rl:column>
        <rl:column bound="false"
            sortable="false"
            headerkey="entitlementorgs.total">
            ${current.total}
        </rl:column>
        <rl:column bound="false"
            sortable="false"
            headerkey="entitlementorgs.used">
            ${current.usage}
        </rl:column>
        <rl:column bound="false"
            sortable="false"
            headerkey="entitlementorgs.proposed_total">
           <html:text property="newCount_${current.orgid}" size="5" value="${current.total}"
                      onkeydown="return blockEnter(event)" />
            <html:submit onclick="this.form.orgClicked.value = '${current.orgid}'"> <bean:message key="entitlementorgs.update"/>
            </html:submit>
            <br><span class="small-text"><bean:message key="entitlementorgs.jsp.possible_vals" arg0="${current.upper}"/></span>
        </rl:column>
    </rl:list>
</rl:listset>

<span class="small-text">
    <bean:message key="entitlementorgs.tip"/>
</span>

<h2><bean:message key="entitlementorgs.usage"/></h2>

<table class="details">
    <tr>
        <th>
            <b><bean:message key="entitlementorgs.total_allocated"/>:</
b>
        </th>
        <td>
            ${maxEnt}
            <p/>
            <div class="small-text">
                <bean:message key="entitlementorgs.tip_allocated"/>
            </div>
        </td>
    </tr>
    <tr>
        <th>
            <b><bean:message key="entitlementorgs.total_inuse"/>:</b>
        </th>
        <td>
            ${curEnt}
            <p/>
        </td>
    </tr>
    <tr>
        <th>
            <b><bean:message key="entitlementorgs.total_orguse"/>:</b>
        </th>
        <td>
            <bean:message key="entitlementorgs.total_orgusedata"
                          arg0="${alloc}" arg1="${orgsnum}" arg2="${ratio}"/>
            <p/>
        </td>
    </tr>
</table>

</body>
</html:html>

