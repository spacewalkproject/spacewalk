<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif">
  <bean:message key="probes.jsp.toolbar"/>
</rhn:toolbar>

<div class="content-nav">
<ul class="content-nav-rowone">
<li class="${criticalClass}"><a href="/rhn/monitoring/ProbeList.do?state=CRITICAL" class="${criticalLink}"><span class="toolbar"><img src="/img/rhn-mon-down.gif"></span><bean:message key="Critical"/> (${criticalCount})</a></li>
<li class="${warningClass}"><a href="/rhn/monitoring/ProbeList.do?state=WARNING" class="${warningLink}"><span class="toolbar"><img src="/img/rhn-mon-warning.gif"></span><bean:message key="Warning"/> (${warningCount})</a></li>
<li class="${unknownClass}"><a href="/rhn/monitoring/ProbeList.do?state=UNKNOWN" class="${unknownLink}"><span class="toolbar"><img src="/img/rhn-mon-unknown.gif"></span><bean:message key="Unknown"/> (${unknownCount})</a></li>
<li class="${pendingClass}"><a href="/rhn/monitoring/ProbeList.do?state=PENDING" class="${pendingLink}"><span class="toolbar"><img src="/img/rhn-mon-pending.gif"></span><bean:message key="Pending"/> (${pendingCount})</a></li>
<li class="${okClass}"><a href="/rhn/monitoring/ProbeList.do?state=OK" class="${okLink}"><span class="toolbar"><img src="/img/rhn-mon-ok.gif"></span><bean:message key="OK"/> (${okCount})</a></li>
<li class="${allClass}"><a href="/rhn/monitoring/ProbeList.do" class="${allLink}"><bean:message key="All"/> (${allCount})</a></li>
</ul>
</div>

<h2><bean:message key="monitoring.probes.jsp.header2"/></h2>

<div>
    <form method="POST" name="rhn_list" action="/rhn/monitoring/ProbeList.do">
    <rhn:list pageList="${requestScope.pageList}" noDataText="monitoring.probes.jsp.noprobes" legend="probes-list">
      <rhn:listdisplay exportColumns="id,description,stateString,stateOutputString,lastCheck">
        <%@ include file="/WEB-INF/pages/common/fragments/probes/probe-state-column.jspf" %>
        <rhn:column header="systemlist.jsp.system">
          <A HREF="/rhn/systems/details/probes/ProbesList.do?sid=${current.serverId}">
            ${current.serverName}
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

