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

<div class="toolbar">
  <c:choose>
    <c:when test="${not empty testResult.comparableId}">
      <a href="/rhn/audit/scap/DiffSubmit.do?first=${testResult.comparableId}&second=${testResult.id}&view=changed">
        <img src="/img/rhn-listicon-${testResult.diffIcon}.gif"
          alt="<bean:message key="scapdiff.jsp.i.${testResult.diffIcon}"/>"
          title="<bean:message key="scapdiff.jsp.i.${testResult.diffIcon}"/>"/>
        <bean:message key="system.audit.xccdftable.jsp.diff"/>
      </a>
    </c:when>
    <c:otherwise>
      <bean:message key="system.audit.xccdftable.jsp.nodiff"/>
    </c:otherwise>
  </c:choose>
  |

  <c:if test="${testResult.deletable}">
    <a href="/rhn/systems/table/audit/XccdfDeleteConfirm.do?sid=${param.sid}&xid=${testResult.id}">
      <i class="icon-trash"
          title="<bean:message key="system.audit.xccdfdelete"/>"></i>
      <bean:message key="system.audit.xccdfdelete"/>
    </a>
  |
  </c:if>

  <a href="/rhn/systems/table/audit/ScheduleXccdf.do?sid=${param.sid}&path=${testResult.scapActionDetails.path}&params=${testResult.scapActionDetails.parametersContents}">
    <img src="/img/restart.png" alt="<bean:message key="system.audit.xccdftable.jsp.reschedule"/>"/>
    <bean:message key="system.audit.xccdftable.jsp.reschedule"/>
  </a>
</div>

<h2><bean:message key="system.audit.xccdftable.jsp.header"/></h2>
<rhn:csrf/>

<table class="table">
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.id"/>:</th>
    <td><c:out value="${testResult.id}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.path"/>:</th>
    <td><c:out value="${testResult.scapActionDetails.path}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.schedulexccdf.jsp.arguments"/>:</th>
    <td><c:out value="${testResult.scapActionDetails.parametersContents}"/></td>
  </tr>
  <tr>
    <th><bean:message key="configoverview.jsp.scheduledBy"/>:</th>
    <td>
      <img src="/img/rhn-listicon-user.gif" alt="<bean:message key="yourrhn.jsp.user.alt" />"/>
      <a href="/network/systems/table/history/event.pxt?sid=${param.sid}&hid=${testResult.scapActionDetails.parentAction.id}">
        <c:out value="${testResult.scapActionDetails.parentAction.schedulerUser.login}"/>
      </a>
    </td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.benchmarkid"/>:</th>
    <td><c:out value="${testResult.benchmark.identifier}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.version"/>:</th>
    <td><c:out value="${testResult.benchmark.version}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.profileid"/>:</th>
    <td><c:out value="${testResult.profile.identifier}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.title"/>:</th>
    <td><c:out value="${testResult.profile.title}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.started"/>:</th>
    <td><c:out value="${testResult.startTime}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.completed"/>:</th>
    <td><c:out value="${testResult.endTime}"/></td>
  </tr>
  <tr>
    <th><bean:message key="system.audit.xccdftable.jsp.errors"/>:</th>
    <td><pre><c:out value="${testResult.errrosContents}"/></pre></th>
  </tr>
  <c:if test="${not empty testResult.files}">
    <tr>
      <th><bean:message key="system.audit.xccdftable.jsp.files"/>:</th>
      <td>
        <c:forEach items="${testResult.files}" var="file">
          <a href="/rhn/systems/table/audit/ScapResultDownload.do?sid=${param.sid}&xid=${param.xid}&name=${file.filename}"
             target="${file.HTML ? '_blank' : '_self'}"><c:out value="${file.filename}"/></a> &nbsp;
        </c:forEach>
      </td>
    </tr>
  </c:if>
</table>

<h2><bean:message key="system.audit.xccdftable.jsp.xccdfrules"/></h2>

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
