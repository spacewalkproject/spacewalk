<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<div class="toolbar">
  <c:choose>
    <c:when test="${not empty testResult.comparableId}">
      <a href="/rhn/audit/scap/DiffSubmit.do?first=${testResult.comparableId}&second=${testResult.id}&view=changed">
         <c:when test="${testResult.diffIcon == 'checked'}" >
            <rhn:icon type="system-ok" title="<bean:message key='scapdiff.jsp.i.checked'/>"/>
         </c:when>
         <c:when test="${testResult.diffIcon == 'alert'}" >
            <rhn:icon type="system-warn" title="<bean:message key='scapdiff.jsp.i.alert'/>"/>
         </c:when>
         <c:when test="${testResult.diffIcon == 'error'}" >
            <rhn:icon type="system-crit" title="<bean:message key='scapdiff.jsp.i.error'/>"/>
         </c:when>
         <c:otherwise>
            <rhn:icon type="system-unknown" title="<bean:message key='system.audit.xccdfdetails.jsp.nodiff'/>"/>
         </c:otherwise>
        <bean:message key="system.audit.xccdfdetails.jsp.diff"/>
      </a>
    </c:when>
    <c:otherwise>
      <bean:message key="system.audit.xccdfdetails.jsp.nodiff"/>
    </c:otherwise>
  </c:choose>
  |

  <c:if test="${testResult.deletable}">
    <a href="/rhn/systems/details/audit/XccdfDeleteConfirm.do?sid=${param.sid}&xid=${testResult.id}">
      <rhn:icon type="item-del" title="<bean:message key='system.audit.xccdfdelete'/>" />
      <bean:message key="system.audit.xccdfdelete"/>
    </a>
  |
  </c:if>

  <a href="/rhn/systems/details/audit/ScheduleXccdf.do?sid=${param.sid}&path=${testResult.scapActionDetails.path}&params=${testResult.scapActionDetails.parametersContents}">
    <img src="/img/restart.png" alt="<bean:message key='system.audit.xccdfdetails.jsp.reschedule'/>"/>
    <bean:message key="system.audit.xccdfdetails.jsp.reschedule"/>
  </a>
</div>

<h2><bean:message key="system.audit.xccdfdetails.jsp.header"/></h2>
<rhn:csrf/>

<table class="details">
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.id"/>:</th>
    <td><c:out value="${testResult.id}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdfdetails.jsp.path"/>:</th>
    <td><c:out value="${testResult.scapActionDetails.path}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.schedulexccdf.jsp.arguments"/>:</th>
    <td><c:out value="${testResult.scapActionDetails.parametersContents}"/></td>
  </tr>
  <tr>
    <th><bean:message key="configoverview.jsp.scheduledBy"/>:</th>
    <td>
      <rhn:icon type="header-user" title="<bean:message key='yourrhn.jsp.user.alt'/>"/>
      <a href="/network/systems/details/history/event.pxt?sid=${param.sid}&hid=${testResult.scapActionDetails.parentAction.id}">
        <c:out value="${testResult.scapActionDetails.parentAction.schedulerUser.login}"/>
      </a>
    </td>
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
    <th><bean:message key="system.audit.xccdfdetails.jsp.title"/>:</th>
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
  </tr>
  <c:if test="${not empty testResult.files}">
    <tr>
      <th><bean:message key="system.audit.xccdfdetails.jsp.files"/>:</th>
      <td>
        <c:forEach items="${testResult.files}" var="file">
          <a href="/rhn/systems/details/audit/ScapResultDownload.do?sid=${param.sid}&xid=${param.xid}&name=${file.filename}"
             target="${file.HTML ? '_blank' : '_self'}"><c:out value="${file.filename}"/></a> &nbsp;
        </c:forEach>
      </td>
    </tr>
  </c:if>
</table>

<h2><bean:message key="system.audit.xccdfdetails.jsp.xccdfrules"/></h2>

<rl:listset name="xccdfDetails">
  <rhn:csrf/>
  <rl:list>
    <rl:decorator name="PageSizeDecorator"/>

    <%@ include file="/WEB-INF/pages/common/fragments/audit/rule-common-columns.jspf" %>

  </rl:list>
  <rl:csv name="xccdfDetails"
    exportColumns="id,documentIdref,identsString,evaluationResult"/>
</rl:listset>

</body>
</html>
