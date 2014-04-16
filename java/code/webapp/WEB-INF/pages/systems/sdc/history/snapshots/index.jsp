<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot">
  <bean:message key="system.history.snapshot.header" />
</rhn:toolbar>

<div class="page-summary">
  <p><bean:message key="system.history.snapshot.summary1" /></p>
  <p><bean:message key="system.history.snapshot.summary2" /></p>
</div>

<rl:listset name="eventSet" legend="system-history">
  <rhn:csrf />
  <input type="hidden" name="sid" value="${param.sid}" />
  <rl:list emptykey="system.history.snapshot.nosnapshot">
    <rl:decorator name="PageSizeDecorator" />
    <rl:decorator name="ElaborationDecorator" />

    <rl:column headerkey="system.history.snapshot.reason">
      <a href="/network/systems/details/history/snapshots/rollback.pxt?sid=${param.sid}&amp;ss_id=${current.id}">${current.reason}</a>
    </rl:column>
    <rl:column headerkey="system.history.snapshot.timetaken">
      ${current.created}
    </rl:column>
    <rl:column headerkey="system.history.snapshot.tags">
      <a href="/network/systems/details/history/snapshots/snapshot_tags.pxt?sid=${param.sid}&amp;ss_id=${current.id}">${current.tag_count}</a>
    </rl:column>
  </rl:list>
</rl:listset>

</body>
</html>
