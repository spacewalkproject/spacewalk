<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

  <h2><bean:message key="actiondetails.jsp.heading2"/></h2>

  <table class="table">
    <tbody>
      <tr>
        <td><bean:message key="actiondetails.jsp.actiontype"/>:</td>
        <td>${requestScope.actiontype}</td>
      </tr>
      <tr>
        <td><bean:message key="actiondetails.jsp.scheduler"/>:</td>
        <td>${requestScope.scheduler}</td>
      </tr>
      <tr>
        <td><bean:message key="actiondetails.jsp.earliestexecution"/>:</td>
        <td>${requestScope.earliestaction}</td>
      </tr>
      <tr>
        <td><bean:message key="actiondetails.jsp.notes"/>:</td>
        <td>${requestScope.actionnotes}</td>
      </tr>
    </tbody>
  </table>

</body>
</html>
