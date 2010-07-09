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

<rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/org_tabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<html:form action="/admin/multiorg/OrgDetails?oid=${oid}">
 <html:hidden property="submitted" value="true"/>
 <h2><bean:message key="orgdetails.jsp.header"/></h2>

 <table class="details" align="center">
  <tr>
    <c:choose>
      <c:when test="${param.oid != 1}">
        <th width="25%"><bean:message key="org.name.jsp"/></th>
         <td><html:text property="orgName" maxlength="128" size="40" />
         <br>
         <span class="small-text"><strong>Tip:</strong>Between 3 and 128 characters</span>
        </td>
      </c:when>
      <c:otherwise>
        <th><bean:message key="org.name.jsp"/></th>
        <td><bean:write name="orgDetailsForm" property="orgName"/></td>
      </c:otherwise>
    </c:choose>
  </tr>
  <tr>
    <th><bean:message key="org.id.jsp"/></th>
    <td><bean:write name="orgDetailsForm" property="id"/></td>
  </tr>
  <tr>
    <th><bean:message key="org.active.users.jsp"/></th>
    <td><a href="/rhn/admin/multiorg/OrgUsers.do?oid=${param.oid}"><bean:write name="orgDetailsForm" property="users"/></a></td>
  </tr>
  <tr>
    <th><bean:message key="org.systems.jsp"/></th>
    <td><bean:write name="orgDetailsForm" property="systems"/></td>
  </tr>
  <tr>
    <th><bean:message key="org.system.groups.jsp"/></th>
    <td><bean:write name="orgDetailsForm" property="groups"/></td>
  </tr>
  <tr>
    <th><bean:message key="org.actkeys.jsp"/></th>
    <td><bean:write name="orgDetailsForm" property="actkeys"/></td>
  </tr>
  <tr>
    <th><bean:message key="org.kickstart.profiles.jsp"/></th>
    <td><bean:write name="orgDetailsForm" property="ksprofiles"/></td>
  </tr>
  <tr>
    <th><bean:message key="org.config.channels.jsp"/></th>
    <td><bean:write name="orgDetailsForm" property="cfgchannels"/></td>
  </tr>

 </table>

 <div align="right">
   <hr/>
   <html:submit>
   <bean:message key="orgdetails.jsp.submit"/>
   </html:submit>
 </div>

</html:form>

</body>
</html:html>
