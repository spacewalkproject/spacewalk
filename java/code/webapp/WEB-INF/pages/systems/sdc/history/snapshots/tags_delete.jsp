<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot">
  <bean:message key="system.history.snapshot.tagDeleteHeader" />
</rhn:toolbar>

<div class="page-summary">
  <bean:message key="system.history.snapshot.tagDeleteSummary" />
</div>

<rl:listset name="SnapshotSet">
  <rhn:csrf />
  <rl:list dataset="pageList" name="pageList"
           emptykey="system.history.snapshot.noTags">
    <rl:decorator name="PageSizeDecorator" />
    <rl:column headerkey="system.history.snapshot.tagName">
      <a href="/network/systems/details/history/snapshots/rollback.pxt?sid=${param.sid}&ss_id=${current.ssId}">${current.name}</a>
    </rl:column>
    <rl:column headerkey="column.created">
      ${current.created}
    </rl:column>
  </rl:list>
  <input type="hidden" name="sid" value="${param.sid}" />
  <input type="submit" name="dispatch" class="btn btn-default pull-right"
    value='<bean:message key="confirm.jsp.confirm"/>'/>
  <rhn:submitted />
</rl:listset>

</body>
</html>
