<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif">
  <bean:message key="probes.jsp.toolbar"/>
</rhn:toolbar>

<div class="spacewalk-content-nav">
  <ul class="nav nav-tabs">
    <li class="${criticalClass}"><a href="/rhn/monitoring/ProbeList.do?state=CRITICAL"><span class="toolbar"><img src="/img/rhn-mon-down.gif"></span><bean:message key="Critical"/> (${criticalCount})</a></li>
    <li class="${warningClass}"><a href="/rhn/monitoring/ProbeList.do?state=WARNING"><span class="toolbar"><img src="/img/rhn-mon-warning.gif"></span><bean:message key="Warning"/> (${warningCount})</a></li>
    <li class="${unknownClass}"><a href="/rhn/monitoring/ProbeList.do?state=UNKNOWN"><span class="toolbar"><img src="/img/rhn-mon-unknown.gif"></span><bean:message key="Unknown"/> (${unknownCount})</a></li>
    <li class="${pendingClass}"><a href="/rhn/monitoring/ProbeList.do?state=PENDING"><span class="toolbar"><img src="/img/rhn-mon-pending.gif"></span><bean:message key="Pending"/> (${pendingCount})</a></li>
    <li class="${okClass}"><a href="/rhn/monitoring/ProbeList.do?state=OK"><span class="toolbar"><img src="/img/rhn-mon-ok.gif"></span><bean:message key="OK"/> (${okCount})</a></li>
    <li class="${allClass}"><a href="/rhn/monitoring/ProbeList.do"><bean:message key="All"/> (${allCount})</a></li>
  </ul>
</div>

<h2><bean:message key="monitoring.probes.jsp.header2"/></h2>

<div>
    <form method="POST" name="rhn_list" action="/rhn/monitoring/ProbeList.do">
    <rhn:csrf />
    <rhn:submitted />
    <html:hidden property="state" value="${state}" />
    <rhn:list pageList="${requestScope.pageList}" noDataText="monitoring.probes.jsp.noprobes" legend="probes-list">
      <rhn:listdisplay exportColumns="id,description,stateString,stateOutputString,lastCheck">
        <%@ include file="/WEB-INF/pages/common/fragments/probes/probe-state-column.jspf" %>
        <rhn:column header="systemlist.jsp.system">
          <A HREF="/rhn/systems/details/probes/ProbesList.do?sid=${current.serverId}">
            <c:out value="${current.serverName}" escapeXml="true" />
          </A>
        </rhn:column>
        <rhn:column header="probes.index.jsp.description">
          <A HREF="/rhn/systems/details/probes/ProbeDetails.do?sid=${current.serverId}&probe_id=${current.id}">
            ${current.description}
          </A>
        </rhn:column>
        <rhn:column header="lastCheck">
          <fmt:formatDate value="${current.lastCheck}" type="both" dateStyle="short" timeStyle="long"/>
        </rhn:column>
      </rhn:listdisplay>
    </rhn:list>
    </form>
</div>

</body>
</html>

