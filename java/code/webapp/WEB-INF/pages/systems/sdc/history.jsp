<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>


<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-event-history">
  <bean:message key="system.event.history.header" />
</rhn:toolbar>

<div class="page-summary">
  <bean:message key="system.event.history.headerSummary" />
  <br/>
  <c:choose>
    <c:when test="${param.pendingActions != 0}">
      <bean:message key="system.event.history.headerPending" arg0="/network/systems/details/history/pending.pxt?sid=${param.sid}" arg1="${param.pendingActions}" />
      <c:if test="${param.isLocked == true}">
        <br/>
        <bean:message key="system.event.history.locked" arg0="/rhn/systems/details/Overview.do?sid=${param.sid}" />
      </c:if>
    </c:when>
    <c:otherwise>
      <bean:message key="system.event.history.headerNoPending" />
    </c:otherwise>
  </c:choose>
</div>

<rl:listset name="eventSet" legend="system-history">
  <rhn:csrf />
  <input type="hidden" name="sid" value="${param.sid}" />
  <rl:list emptykey="system.event.history.noevent">
    <rl:decorator name="PageSizeDecorator" />
    <rl:decorator name="ElaborationDecorator" />
    <rl:column headerkey="system.event.history.type">
      <c:choose>
        <c:when test="${current.historyType == 'event-type-package'}">
          <rhn:icon type="event-type-package" />
        </c:when>
        <c:when test="${current.historyType == 'event-type-preferences'}">
          <rhn:icon type="event-type-errata" />
        </c:when>
        <c:when test="${current.historyType == 'event-type-errata'}">
          <rhn:icon type="event-type-errata" />
        </c:when>
        <c:otherwise>
          <rhn:icon type="event-type-system" />
        </c:otherwise>
      </c:choose>
    </rl:column>
    <rl:column headerkey="system.event.history.status">
      <c:choose>
        <c:when test="${current.historyStatus == 'Completed'}">
          <rhn:icon type="action-ok" />
        </c:when>
        <c:when test="${current.historyStatus == 'Failed'}">
          <rhn:icon type="action-failed" />
        </c:when>
        <c:when test="${current.historyStatus == 'Picked Up'}">
          <rhn:icon type="action-running" />
        </c:when>
        <c:otherwise>
          ${current.historyStatus}
        </c:otherwise>
      </c:choose>
    </rl:column>
    <rl:column headerkey="system.event.history.summary">
      <a href="/network/systems/details/history/event.pxt?sid=${param.sid}&amp;hid=${current.id}">${current.summary}</a>
    </rl:column>
    <rl:column headerkey="system.event.history.time">
      ${current.completed}
    </rl:column>
  </rl:list>
</rl:listset>

</body>
</html>
