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
    <li class="${criticalClass}"><a href="/rhn/monitoring/ProbeList.do?state=CRITICAL"><i class="icon-exclamation-sign text-error"></i><bean:message key="Critical"/><span class="badge">${criticalCount}</span></a></li>
    <li class="${warningClass}"><a href="/rhn/monitoring/ProbeList.do?state=WARNING"><i class="icon-warning-sign text-warning"></i><bean:message key="Warning"/><span class="badge">${warningCount}</span></a></li>
    <li class="${unknownClass}"><a href="/rhn/monitoring/ProbeList.do?state=UNKNOWN"><i class="icon-question-sign text-info"></i><bean:message key="Unknown"/><span class="badge">${unknownCount}</span></a></li>
    <li class="${pendingClass}"><a href="/rhn/monitoring/ProbeList.do?state=PENDING"><i class="icon-time text-info"></i><bean:message key="Pending"/><span class="badge">${pendingCount}</span></a></li>
    <li class="${okClass}"><a href="/rhn/monitoring/ProbeList.do?state=OK"><i class="icon-ok text-success"></i><bean:message key="OK"/><span class="badge">${okCount}</span></a></li>
    <li class="${allClass}"><a href="/rhn/monitoring/ProbeList.do"><bean:message key="All"/><span class="badge">${allCount}</span></a></li>
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

