<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

<html:errors/>
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

  <h2><bean:message key="actiondetails.jsp.heading2"/></h2>

  <table class="details">
    <tr>
      <th><bean:message key="actiondetails.jsp.actiontype"/>:</th>
      <td>${requestScope.actiontype}</td>
    </tr>
    <tr>
      <th><bean:message key="actiondetails.jsp.scheduler"/>:</th>
      <td>${requestScope.scheduler}</td>
    </tr>
    <tr>
      <th><bean:message key="actiondetails.jsp.earliestexecution"/>:</th>
      <td>${requestScope.earliestaction}</td>
    </tr>
    <tr>
      <th><bean:message key="actiondetails.jsp.notes"/>:</th>
      <td>${requestScope.actionnotes}</td>
    </tr>
  </table>

</body>
</html>
