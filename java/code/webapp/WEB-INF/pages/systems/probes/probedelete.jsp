<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="probdelete.jsp.header" /></h2>

<div class="page-summary">
    <p><bean:message key="probdelete.jsp.multiple" /></p>
</div>
<form method="post" name="rhn_list" action="/rhn/systems/details/probes/ProbesDeleteConfirm.do?sid=${system.id}">
<rhn:csrf />

<rl:listset name="probeDeleteList" legend="system">
  <rl:list emptykey="nosystems.message">

    <rl:decorator name="ElaborationDecorator"/>

    <%@ include file="/WEB-INF/pages/common/fragments/probes/probe-state-column-new.jspf" %>

        <rl:column sortable="true"
                           bound="false"
                   headerkey="probes.index.jsp.description"
                   sortattr="description"
                   defaultsort="asc"
                   filterattr="description"
                   >
                <a href="ProbeDetails.do?probe_id=${current.id}&sid=${system.id}">${current.description}</a>
        </rl:column>

        <rl:column sortable="true"
                           bound="false"
                   headerkey="probes.index.jsp.status"
                   sortattr="stateOutputString">
                ${current.stateOutputString}
        </rl:column>

        <rl:column sortable="false"
                           bound="false"
                   headerkey="probes.index.jsp.type"
                   >
                <c:if test="${current.isSuiteProbe}">
                  <a title='<bean:message key="probes.index.jsp.suiteedit"/>' href="/rhn/monitoring/config/ProbeSuiteProbeEdit.do?suite_id=${current.probeSuiteId}&probe_id=${current.id}"><bean:message key="probes.index.jsp.suite"/></a>
                </c:if>
                <c:if test="${not current.isSuiteProbe}">
                  <a title='<bean:message key="probes.index.jsp.systemedit"/>' href="ProbeEdit.do?probe_id=${current.id}&sid=${system.id}"><bean:message key="probes.index.jsp.system"/></a>
                </c:if>
        </rl:column>

  </rl:list>

  <div class="text-right">
  <hr/>
    <html:hidden property="sid" value="${system.id}"/>
    <html:submit styleClass="btn btn-success" property="dispatch">
        <bean:message key="deleteconfirm.jsp.confirm"/>
    </html:submit>
  </div>

</rl:listset>

</form>
</body>
</html>
