<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:xhtml/>
<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="system.audit.ruledetails.jsp.heading"/></h2>
<rhn:csrf/>

<table class="details">
  <tr>
    <th><bean:message key="system.audit.ruledetails.jsp.idref"/>:</th>
    <td><c:out value="${ruleResult.documentIdref}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.ruledetails.jsp.result"/>:</th>
    <td><c:out value="${ruleResult.label}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.ruledetails.jsp.parent"/>:</th>
    <td>
      <a href="/rhn/systems/details/audit/XccdfDetails.do?sid=${param.sid}&xid=${ruleResult.testResult.id}">
        <c:out value="${ruleResult.testResult.identifier}"/>
      </a>
    </td>
  </tr>
</table>

<h2><bean:message key="system.audit.ruledetails.jsp.assignedidents"/></h2>

<rl:listset name="groupSet">
  <rl:list emptykey="system.audit.ruledetails.jsp.noidents">
    <rhn:csrf/>

    <rl:column headerkey="system.audit.ruledetails.jsp.system" sortattr="system" sortable="true">
      <c:out value="${current.system}"/>
    </rl:column>
    <rl:column headerkey="system.audit.ruledetails.jsp.ident" sortattr="identifier" sortable="true">
      <c:out value="${current.identifier}"/>
    </rl:column>
  </rl:list>
</rl:listset>

</body>
</html>
