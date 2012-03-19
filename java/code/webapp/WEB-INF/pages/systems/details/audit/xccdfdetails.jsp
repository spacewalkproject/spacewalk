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

<h2><bean:message key="system.audit.xccdfdetails.jsp.header"/></h2>
<rhn:csrf/>

<table class="details">
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.path"/>:</th>
    <td><c:out value="${testResult.scapActionDetails.path}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.benchmarkid"/>:</th>
    <td><c:out value="${testResult.benchmark.identifier}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.version"/>:</th>
    <td><c:out value="${testResult.benchmark.version}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.profileid"/>:</th>
    <td><c:out value="${testResult.profile.identifier}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.title"/></th>
    <td><c:out value="${testResult.profile.title}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.started"/>:</th>
    <td><c:out value="${testResult.startTime}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.completed"/>:</th>
    <td><c:out value="${testResult.endTime}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.errors"/>:</th>
    <td><pre><c:out value="${testResult.errrosContents}"/></pre></th>
</table>

<h2><bean:message key="system.audit.xccdfdetails.jsp.xccdfrules"/></h2>

<rl:listset name="groupSet" legend="xccdf">
  <rl:list>
    <rl:decorator name="PageSizeDecorator"/>
    <rhn:csrf/>

    <rl:column headerkey="system.audit.xccdfdetails.jsp.scheme" sortattr="system" sortable="true">
      <c:out value="${current.system}"/>
    </rl:column>
    <rl:column headerkey="system.audit.xccdfdetails.jsp.ident" sortattr="identifier" sortable="true">
      <c:out value="${current.identifier}"/>
    </rl:column>
    <rl:column headerkey="system.audit.xccdfdetails.jsp.result" sortattr="label" sortable="true" filterattr="label">
      <c:out value="${current.label}"/>
    </rl:column>
  </rl:list>
</rl:listset>

</body>
</html>
