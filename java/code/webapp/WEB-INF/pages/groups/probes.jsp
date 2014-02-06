<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/groups/header.jspf" %>

<rhn:toolbar base="h2" icon="header-system" helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s4-sm-system-details-probes">
  <bean:message key="probes.index.jsp.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
  <p>
    <bean:message key="probes.groups.jsp.summary"/>
  </p>
</div>


<rl:listset name="probeSet">

<rhn:csrf />
<rhn:submitted />
<rl:list emptykey="probes.groups.jsp.noprobes"
	alphabarcolumn="description"
	styleclass="list">

  <rl:decorator name="PageSizeDecorator"/>
  <rl:decorator name="ElaborationDecorator"/>

  <%@ include file="/WEB-INF/pages/common/fragments/probes/probe-state-column-new.jspf" %>

  <rl:column sortable="true"
        bound="false"
        headerkey="probes.index.jsp.system"
        sortattr="serverName"
        defaultsort="asc"
        filterattr="serverName">

    <a href="/rhn/systems/details/probes/ProbesList.do?sid=${current.serverId}">${current.serverName}</a>

  </rl:column>

  <rl:column sortable="true"
	bound="false"
	headerkey="probes.index.jsp.description"
	sortattr="description"
	defaultsort="asc">

    <a href="/rhn/systems/details/probes/ProbeDetails.do?probe_id=${current.id}&sid=${current.serverId}">${current.description}</a>

  </rl:column>

  <rl:column sortable="true"
	bound="false"
	headerkey="probes.index.jsp.status"
	sortattr="stateOutputString">

    ${current.stateOutputString}

  </rl:column>

  <rl:column sortable="false"
	bound="false"
	headerkey="probes.index.jsp.type">

    <c:if test="${current.isSuiteProbe}">
      <a title='<bean:message key="probes.index.jsp.suiteedit"/>' href="/rhn/monitoring/config/ProbeSuiteProbeEdit.do?suite_id=${current.probeSuiteId}&probe_id=${current.id}">
        <bean:message key="probes.index.jsp.suite"/>
      </a>
    </c:if>
    <c:if test="${not current.isSuiteProbe}">
      <a title='<bean:message key="probes.index.jsp.systemedit"/>' href="/rhn/systems/details/probes/ProbeEdit.do?probe_id=${current.id}&sid=${current.serverId}">
        <bean:message key="probes.index.jsp.system"/>
      </a>
    </c:if>
  </rl:column>

  <rl:column sortable="true"
        bound="false"
        headerkey="lastCheck"
        sortattr="lastCheck">

    <fmt:formatDate value="${current.lastCheck}" type="both" dateStyle="short" timeStyle="long"/>

  </rl:column>

</rl:list>

<input type="hidden" name="sgid" value="${sgid}" />

<rl:csv  exportColumns="id,serverName,description,stateString,stateOutputString,lastCheck"/>

</rl:listset>

</body>
</html>
