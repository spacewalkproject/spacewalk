<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot" creationUrl="SnapshotTagCreate.do?sid=${param.sid}&ss_id=${param.ss_id}" creationType="snapshot" iconAlt="info.alt.img">
  ${param.snapshot_created} <bean:message key="system.history.snapshot.tagSingleHeader" />
</rhn:toolbar>

<div class="page-summary">
  <bean:message key="system.history.snapshot.tagSingleSummary" arg0="${param.ss_name}"/>
</div>

<rl:listset name="SnapshotSet">
  <rhn:csrf />
  <rl:list emptykey="system.history.snapshot.noTags"
           filter="com.redhat.rhn.frontend.taglibs.list.filters.SnapshotTagFilter">
    <rl:decorator name="PageSizeDecorator" />
    <rl:decorator name="ElaborationDecorator" />
    <rl:column headerkey="system.history.snapshot.tagName">
      <a href="/network/systems/details/history/snapshots/rollback.pxt?sid=${param.sid}&ss_id=${current.ssId}">${current.name}</a>
    </rl:column>
    <rl:column headerkey="system.history.snapshot.tagAppliedToSnapshot">
      ${current.created}
    </rl:column>
  </rl:list>
  <input type="hidden" name="sid" value="${param.sid}" />
</rl:listset>

</body>
</html>
