<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>


<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-event-history">
  <bean:message key="${headerLabel}" />
</rhn:toolbar>

<html:form method="post" action="/systems/details/history/Event.do?sid=${system.id}&aid=${requestScope.aid}">

<html:hidden property="submitted" value="true"/>
<rhn:csrf />

<div class="panel panel-default">
  <ul class="list-group">
    <li class="list-group-item">
      <div class="row">
        <div class="col-sm-2">
          <strong><bean:message key="system.event.summary"/></strong>
        </div>
        <div class="col-sm-10">
          <c:choose>
            <c:when test="${requestScope.scheduler != null}">
          <bean:message key="system.event.summaryText" arg0="${requestScope.actiontype}" arg1="${requestScope.scheduler}" />
            </c:when>
            <c:otherwise>
              <c:out value="${requestScope.actiontype}" />
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </li>
    <li class="list-group-item">
      <div class="row">
        <div class="col-sm-2">
          <strong><bean:message key="system.event.details"/></strong>
        </div>
        <div class="col-sm-10">
          <c:out value="${requestScope.actionnotes}" escapeXml="false"/><!-- already html-escaped in backend -->
        </div>
      </div>
    </li>
    <li class="list-group-item">
      <div class="row">
        <div class="col-sm-2">
          <strong><bean:message key="system.event.time"/></strong>
        </div>
        <div class="col-sm-10">
          ${requestScope.earliestaction}
        </div>
      </div>
    </li>
    <c:if test="${requestScope.failed == true}">
    <li class="list-group-item">
      <div class="row">
        <div class="col-sm-2">
          <strong><bean:message key="system.event.reschedule"/></strong>
        </div>
        <div class="col-sm-10">
          <bean:message key="system.event.rescheduleText"/>
        </div>
      </div>
    </li>
    </c:if>
  </ul>
</div>

<c:if test="${requestScope.failed == true}">
  <div align="right">
    <hr/>
    <input type="hidden" name="aid" value="${requestScope.aid}" />
    <html:submit styleClass="btn btn-default">
      <bean:message key="system.event.rescheduleButton"/>
    </html:submit>
  </div>
</c:if>

<rhn:icon type="nav-up" title="system.event.returnIcon"/><a href="${referrerLink}?sid=${system.id}"><bean:message key="${linkLabel}" arg0="${fn:escapeXml(system.name)}" /></a>

</html:form>

</body>

</html>
