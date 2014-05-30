<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot">
  ${param.snapshot_created} <bean:message key="system.history.snapshot.unservableHeader" />
</rhn:toolbar>

<div class="page-summary">
  <bean:message key="system.history.snapshot.unservableSummary" />
</div>

<rl:listset name="ChannelSet">
  <rhn:csrf />
  <rl:list emptykey="system.history.snapshot.cfgFilesEmpty"
    filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageFilter">
    <rl:decorator name="PageSizeDecorator" />
    <rl:decorator name="ElaborationDecorator" />
    <rl:column headerkey="column.package">
      ${current.nvrea}
    </rl:column>
  </rl:list>
  <input type="hidden" name="sid" value="${param.sid}" />
  <input type="hidden" name="ss_id" value="${param.ss_id}" />
</rl:listset>

</body>
</html>
