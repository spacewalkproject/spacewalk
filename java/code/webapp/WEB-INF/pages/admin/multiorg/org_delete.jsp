<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif">
  <bean:message key="orgdelete.jsp.header1" arg0="${orgName}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/org_tabs.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<html:form action="/admin/multiorg/DeleteOrg?oid=${oid}">
 <html:hidden property="submitted" value="true"/>
 <h2><bean:message key="orgdelete.jsp.header2"/></h2>

 <table class="details" align="center">
  <tr>
    <th width="25%"><bean:message key="org.name.jsp"/></th>
    <td>${orgName}</td>
  </tr>
  <tr>
    <th><bean:message key="org.active.users.jsp"/></th>
    <td>${users}</td>
  </tr>
  <tr>
    <th><bean:message key="org.systems.jsp"/></th>
    <td>${systems}</td>
  </tr>
  <tr>
    <th><bean:message key="org.system.groups.jsp"/></th>
    <td>${groups}</td>
  </tr>
  <tr>
    <th><bean:message key="org.actkeys.jsp"/></th>
    <td>${actkeys}</td>
  </tr>
  <tr>
    <th><bean:message key="org.kickstart.profiles.jsp"/></th>
    <td>${ksprofiles}</td>
  </tr>
  <tr>
    <th><bean:message key="org.config.channels.jsp"/></th>
    <td>${cfgchannels}</td>
  </tr>

 </table>

 <div align="right">
   <hr/>
   <html:submit>
   <bean:message key="orgdelete.jsp.submit"/>
   </html:submit>
 </div>

</html:form>

</body>
</html>
