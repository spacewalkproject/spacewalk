<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot">
  ${param.snapshot_created} <bean:message key="system.history.snapshot.header-packages" />
</rhn:toolbar>

<div class="page-summary">
  <p><bean:message key="system.history.snapshot.summary-packages" /></p>
</div>

<rl:listset name="eventSet" legend="system-history">
  <rhn:csrf />
  <rhn:hidden name="sid" value="${param.sid}" />
  <rhn:hidden name="ss_id" value="${param.ss_id}" />
  <rl:list emptykey="system.history.snapshot.nopackagediff"
           alphabarcolumn="package_name"
           filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageNameFilter">
    <rl:decorator name="PageSizeDecorator" />
    <rl:decorator name="ElaborationDecorator" />

    <rl:column headerkey="column.package" sortattr="package_name">${current.package_name}</rl:column>
    <rl:column headerkey="column.architecture">${current.arch}</rl:column>
    <rl:column headerkey="column.current-version">${current.server_nvrea}</rl:column>
    <rl:column headerkey="column.snapshot-version">${current.snapshot_nvrea}</rl:column>
    <rl:column headerkey="column.difference">
      <c:choose>
          <c:when test="${current.comparison == 2}">
              <bean:message key="system.history.snapshot.profileonly" />
          </c:when>
          <c:when test="${current.comparison == 1}">
              <bean:message key="system.history.snapshot.profilenewer" />
          </c:when>
          <c:when test="${current.comparison == -1}">
              <bean:message key="system.history.snapshot.snapshotnewer" />
          </c:when>
          <c:when test="${current.comparison == -2}">
              <bean:message key="system.history.snapshot.snapshotonly" />
          </c:when>
      </c:choose>
    </rl:column>
  </rl:list>
</rl:listset>

</body>
</html>
