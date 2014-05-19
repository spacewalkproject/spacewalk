<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-event-history">
  <bean:message key="system.event.pending.cancel" />
</rhn:toolbar>

<div class="page-summary">
  <bean:message key="system.event.pending.cancelSummary" />
</div>

<form method="post" name="rhn_list" action="/rhn/systems/details/history/PendingDelete.do?sid=${param.sid}">

<rl:listset name="eventSet" legend="system-history-type">
  <rhn:csrf />
  <input type="hidden" name="sid" value="${param.sid}" />
  <rl:list dataset="pageList" name="eventList" emptykey="system.event.pending.noevent">
    <rl:decorator name="PageSizeDecorator" />
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
    <rl:column headerkey="system.event.history.summary">
      <a href="/network/systems/details/history/event.pxt?sid=${param.sid}&amp;hid=${current.id}">${current.summary}</a>
    </rl:column>
    <rl:column headerkey="system.event.pending.earliest">
      ${current.scheduledFor}
    </rl:column>
  </rl:list>

  <div align="right">
    <hr/>
    <input type="hidden" name="sid" value="${sid}" />
    <input type="submit" name="dispatch" class="btn btn-default"
      value='<bean:message key="system.event.pending.confirm"/>'/>
  </div>
  <rhn:submitted />
</rl:listset>

</body>
</html>
