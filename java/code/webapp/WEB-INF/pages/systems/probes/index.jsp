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
        <meta name="page-decorator" content="none" />
    </head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-system" helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s4-sm-system-details-probes"
    creationUrl="/rhn/systems/details/probes/ProbeCreate.do?sid=${system.id}"
    creationType="probe" >
<bean:message key="probes.index.jsp.toolbar"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="probes.index.jsp.summary"/>
    </p>
  </div>


<rl:listset name="probeSet">

<rhn:csrf />
<rhn:submitted />
<rl:list emptykey="probes.index.jsp.noprobes"
		alphabarcolumn="description"
		styleclass="list"
		>
			<rl:decorator name="PageSizeDecorator"/>
            <rl:decorator name="SelectableDecorator"/>
            <rl:decorator name="ElaborationDecorator"/>


            <rl:selectablecolumn value="${current.selectionKey}"
                 selected="${current.selected}"/>

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
    <input type="hidden" name="sid" value="${sid}" />
    <input type="submit" name="dispatch"
        value='<bean:message key="probdelete.jsp.deleteprobes"/>'/>
  </div>
 <rl:csv  exportColumns="id,description,stateString,stateOutputString"/>
</rl:listset>











</body>
</html>
