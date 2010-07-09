<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:html xhtml="true">
<head>
</head>
<body>
<c:choose>
<c:when test="${param.oid != 1}">
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
	miscUrl="${url}"
	miscAcl="user_role(org_admin)"
	miscText="${text}"
	miscImg="${img}"
	miscAlt="${text}"
	deletionUrl="/rhn/admin/multiorg/DeleteOrg.do?oid=${param.oid}"
	deletionAcl="user_role(satellite_admin)"
	deletionType="org"
	imgAlt="users.jsp.imgAlt">
	<c:out escapeXml="true" value="${org.name}" />
</rhn:toolbar>
</c:when>
<c:otherwise>
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
	miscUrl="${url}"
	miscAcl="user_role(org_admin)"
	miscText="${text}"
	miscImg="${img}"
	miscAlt="${text}"
	imgAlt="users.jsp.imgAlt">
	<c:out escapeXml="true" value="${org.name}" />
</rhn:toolbar>
</c:otherwise>
</c:choose>

<rhn:dialogmenu mindepth="0" maxdepth="3" definition="/WEB-INF/nav/org_tabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="orgsysubs.jsp.header2"/></h2>

<bean:message key="orgsoftwaresubs.jsp.description" arg0="${org.name}"/>
<p>
<html:form action="/admin/multiorg/OrgSystemSubscriptions.do">
 <html:hidden property="submitted" value="true"/>
 <html:hidden property="oid" value="${param.oid}"/>


  <table class="list" cellpadding="0" cellspacing="0" width="100%">
    <thead>
        <tr>
            <th><bean:message key="orgsystemsubs.jsp.ent_name"/></th>
            <th><bean:message key="orgsystemsubs.jsp.total"/></th>
            <th><bean:message key="orgsystemsubs.jsp.usage"/></th>
            <th><bean:message key="orgsystemsubs.jsp.proposed_total"/></th>
        </tr>
        </thead>
        <tbody>
            <tr class="list-row-odd">
                <td class="first-column">
                <strong><bean:message key="enterprise_entitled"/> <bean:message key="orgsystemsubs.jsp.base"/></strong>
                <br>
                <span class="small-text"><bean:message key="orgsystemsubs.jsp.man_tip"/></span>
                </td>
                <td>
                ${enterprise_entitled.maxEntitlements}
                </td>
                <td>
                ${enterprise_entitled.currentEntitlements}
                </td>
                <td class="last-column">
                <c:choose>
                  <c:when test="${param.oid != 1}">
                    <html:text property="enterprise_entitled"
                               onkeydown="return blockEnter(event)"/>
                    <br><span class="small-text"><bean:message key="orgsystemsubs.jsp.possible_vals" arg0="0" arg1="${enterprise_entitled.upperRange}"/></span>
                  </c:when>
                  <c:otherwise>
                     <bean:write name="orgSystemSubscriptionsForm" property="enterprise_entitled"/>
                  </c:otherwise>
                </c:choose>
                </td>
            </tr>
            <tr class="list-row-even">
                <td class="first-column">
                <strong><bean:message key="monitoring_entitled"/> <bean:message key="orgsystemsubs.jsp.add_on"/></strong>
                <br>
                <span class="small-text"><bean:message key="orgsystemsubs.jsp.mon_tip"/></span>
                </td>
                <td>
                ${monitoring_entitled.maxEntitlements}
                </td>
                <td>
                ${monitoring_entitled.currentEntitlements}
                </td>
                <td class="last-column">
                  <c:choose>
                  <c:when test="${param.oid != 1}">
                    <html:text property="monitoring_entitled"
                               onkeydown="return blockEnter(event)"/>
                    <br><span class="small-text"><bean:message key="orgsystemsubs.jsp.possible_vals" arg0="0" arg1="${monitoring_entitled.upperRange}"/></span>
                  </c:when>
                  <c:otherwise>
                     <bean:write name="orgSystemSubscriptionsForm" property="monitoring_entitled"/>
                  </c:otherwise>
                </c:choose>
                </td>
            </tr>
            <tr class="list-row-odd">
                <td class="first-column">
                <strong><bean:message key="provisioning_entitled"/> <bean:message key="orgsystemsubs.jsp.add_on"/></strong>
                <br>
                <span class="small-text"><bean:message key="orgsystemsubs.jsp.provis_tip"/></span>
                </td>
                <td>
                ${provisioning_entitled.maxEntitlements}
                </td>
                <td>
                ${provisioning_entitled.currentEntitlements}
                </td>
                <td class="last-column">
                  <c:choose>
                  <c:when test="${param.oid != 1}">
                    <html:text property="provisioning_entitled"
                               onkeydown="return blockEnter(event)"/>
                    <br><span class="small-text"><bean:message key="orgsystemsubs.jsp.possible_vals" arg0="0" arg1="${provisioning_entitled.upperRange}"/></span>
                  </c:when>
                  <c:otherwise>
                     <bean:write name="orgSystemSubscriptionsForm" property="provisioning_entitled"/>
                  </c:otherwise>
                </c:choose>
                </td>
            </tr>
            <tr class="list-row-even">
                <td class="first-column">
                <strong><bean:message key="virtualization_host"/> <bean:message key="orgsystemsubs.jsp.add_on"/></strong>
                <br>
                <span class="small-text"><bean:message key="orgsystemsubs.jsp.virt_tip"/></span>
                </td>
                <td>
                ${virtualization_host.maxEntitlements}
                </td>
                <td>
                ${virtualization_host.currentEntitlements}
                </td>
                <td class="last-column">
                  <c:choose>
                  <c:when test="${param.oid != 1}">
                    <html:text property="virtualization_host"
                               onkeydown="return blockEnter(event)"/>
                    <br><span class="small-text"><bean:message key="orgsystemsubs.jsp.possible_vals" arg0="0" arg1="${virtualization_host.upperRange}"/></span>
                  </c:when>
                  <c:otherwise>
                     <bean:write name="orgSystemSubscriptionsForm" property="virtualization_host"/>
                  </c:otherwise>
                </c:choose>
                </td>
            </tr>
            <tr class="list-row-odd">
                <td class="first-column">
                <strong><bean:message key="virtualization_host_platform"/> <bean:message key="orgsystemsubs.jsp.add_on"/></strong>
                <br>
                <span class="small-text"><bean:message key="orgsystemsubs.jsp.virt_plat_tip"/></span>
                </td>
                <td>
                ${virtualization_host_platform.maxEntitlements}
                </td>
                <td>
                ${virtualization_host_platform.currentEntitlements}
                </td>
                <td class="last-column">
                  <c:choose>
                  <c:when test="${param.oid != 1}">
                    <html:text property="virtualization_host_platform"
                               onkeydown="return blockEnter(event)"/>
                    <br><span class="small-text"><bean:message key="orgsystemsubs.jsp.possible_vals" arg0="0" arg1="${virtualization_host_platform.upperRange}"/></span>
                  </c:when>
                  <c:otherwise>
                     <bean:write name="orgSystemSubscriptionsForm" property="virtualization_host_platform"/>
                  </c:otherwise>
                </c:choose>
                </td>
            </tr>
        </tbody>
        </table>
<c:if test="${param.oid != 1}">
 <div align="right">
   <hr/>
   <html:submit>
   <bean:message key="orgdetails.jsp.submit"/>
   </html:submit>
 </div>
</c:if>
</html:form>

</body>
</html:html>
