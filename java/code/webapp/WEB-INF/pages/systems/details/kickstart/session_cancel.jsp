<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="kickstart.session_cancel.jsp.header2"/></h2>

<bean:message key="kickstart.session_cancel.jsp.summary" />
<p>

<html:form method="POST" action="/systems/table/kickstart/SessionCancel.do">
  <rhn:csrf />
  <table class="table">
    <tr>
      <th><bean:message key="kickstarttable.jsp.label" /></th>
      <td><a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${ksession.ksdata.id}">${ksession.ksdata.label}</td>
    </tr>
    <tr>
      <th><bean:message key="kickstart.session_cancel.jsp.state" /></th>
      <td>${ksession.state.description}</td>
    </tr>
    <html:hidden property="sid" value="${system.id}"/>
    <html:hidden property="submitted" value="true"/>
  </table>
  <hr>
  <div class="text-right"><html:submit><bean:message key="kickstart.session_cancel.jsp.cancel"/></html:submit></div>
</html:form>
</body>
</html>

