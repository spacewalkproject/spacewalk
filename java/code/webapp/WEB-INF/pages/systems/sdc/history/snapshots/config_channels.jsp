<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot">
  ${param.snapshot_created} <bean:message key="system.history.snapshot.cfgChannelHeader" />
</rhn:toolbar>

<div class="page-summary">
  <bean:message key="system.history.snapshot.cfgChannelSummary" />
</div>

<rl:listset name="ChannelSet">
  <rhn:csrf />
  <rl:list emptykey="system.history.snapshot.cfgChannelEmpty">
    <rl:decorator name="PageSizeDecorator" />
    <rl:decorator name="ElaborationDecorator" />
    <rl:column headerkey="system.history.snapshot.cfgChannel">
      <a href="/rhn/configuration/ChannelOverview.do?ccid=${current.id}">${current.name}</a>
    </rl:column>
    <rl:column headerkey="globalconfiglist.jsp.label">
      ${current.label}
    </rl:column>
    <rl:column headerkey="column.difference">
      <c:choose>
        <c:when test="${current.comparison == -1}">
          <bean:message key="system.history.snapshot.cfgSnapshotOnly" />
        </c:when>
        <c:when test="${current.comparison == 1}">
          <bean:message key="system.history.snapshot.cfgProfileOnly" />
        </c:when>
      </c:choose>
    </rl:column>
  </rl:list>
  <rhn:hidden name="sid" value="${param.sid}" />
  <rhn:hidden name="ss_id" value="${param.ss_id}" />
</rl:listset>

</body>
</html>
