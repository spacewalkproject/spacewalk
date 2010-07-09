<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<html:xhtml/>
<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
<br>

<c:if test="${is_suite_probe}">
  <rhn:toolbar base="h2" img="/img/rhn-icon-system.gif"
      miscAlt="probedetails.jsp.editsuiteprobe"
      miscImg="action-clone.gif"
      miscUrl="/rhn/monitoring/config/ProbeSuiteProbeEdit.do?suite_id=${probe.templateProbe.probeSuite.id}&amp;probe_id=${probe.templateProbe.id}"
      miscText="probedetails.jsp.editsuiteprobe"
      creationUrl="/rhn/systems/details/probes/ProbeCreate.do?sid=${system.id}"
      creationType="probe">
   <bean:message key="probedetails.jsp.currentstate" />
  </rhn:toolbar>
</c:if>
<c:if test="${not is_suite_probe}">
  <rhn:toolbar base="h2" img="/img/rhn-icon-system.gif"
      deletionUrl="/rhn/systems/details/probes/ProbeDelete.do?probe_id=${probe.id}&amp;sid=${system.id}"
      deletionType="probe"
      miscAlt="probedetails.jsp.editthisprobe"
      miscImg="action-clone.gif"
      miscUrl="ProbeEdit.do?probe_id=${probe.id}&amp;sid=${system.id}"
      miscText="probedetails.jsp.editthisprobe"
      creationUrl="/rhn/systems/details/probes/ProbeCreate.do?sid=${system.id}"
    creationType="probe">
   <bean:message key="probedetails.jsp.currentstate" />
  </rhn:toolbar>
</c:if>
<br>
<table class="details">
  <tr>
    <th><bean:message key="probedetails.jsp.probe" /></th>
    <td>${probe.description}</td>
  </tr>
  <tr>
      <th><bean:message key="probeedit.jsp.satclusterdesc" /></th>
      <td colspan="3">${probe.satCluster.description}</td>
  </tr>
  <tr>
    <th><bean:message key="probedetails.jsp.status" /></th>
    <td class=${status_class}>${status}</td>
  </tr>
  <tr>
    <th><bean:message key="probedetails.jsp.last_update" /></th>
    <td><fmt:formatDate value="${probe.state.lastCheck}" type="both" dateStyle="short" timeStyle="long"/></td>
  </tr>
</table>
<html:form action="/systems/details/probes/ProbeDetails" method="get">
  <table class="details">
    <!-- For some reason we cant render date picker during export. -->
    <c:if test="${param.lde != 1}">
      <tr>
        <th><bean:message key="probedetails.jsp.start_date" /></th>
        <td><jsp:include page="../../common/fragments/date-picker.jsp">
              <jsp:param name="widget" value="start"/>
            </jsp:include>
        </td>
      </tr>
      <tr>
        <th><bean:message key="probedetails.jsp.end_date" /></th>
        <td><jsp:include page="../../common/fragments/date-picker.jsp">
              <jsp:param name="widget" value="end"/>
            </jsp:include></td>
      </tr>
    </c:if>
    <tr>
      <th > <bean:message key="probedetails.jsp.metrics" /></th>
      <td >
        <html:select size="3" multiple="true" property="selected_metrics">
          <html:options collection="metrics"
            property="value"
            labelProperty="label" />
        </html:select>
      </td>
    </tr>
    <tr>
      <th><bean:message key="probedetails.jsp.show_graph" /></th>
      <td><html:checkbox property="show_graph" /></td>
    </tr>
    <tr>
      <th><bean:message key="probedetails.jsp.show_event_log" /></th>
      <td><html:checkbox property="show_log" /></td>
    </tr>
    <tr>
      <td><html:submit><bean:message key="probedetails.jsp.generate_report"/></html:submit></td>
    </tr>
  </table>
  <html:hidden property="sid" value="${param.sid}"/>
  <html:hidden property="probe_id" value="${probe.id}"/>
  <html:hidden property="submitted" value="true"/>
</html:form>
  <c:if test="${requestScope.show_graph}">
  <h2><bean:message key="probedetails.jsp.graph"/></h2>
    <img src="/rhn/systems/details/probes/ProbeGraph.do?${requestScope.l10ned_selected_metrics_string}${requestScope.selected_metrics_string}startts=${requestScope.startts}&amp;endts=${requestScope.endts}&amp;sid=${system.id}&amp;probe_id=${probe.id}"/>
    <br><a href="/rhn/systems/details/probes/ProbeGraph.do?lde=1&${requestScope.l10ned_selected_metrics_string}${requestScope.selected_metrics_string}startts=${requestScope.startts}&amp;endts=${requestScope.endts}&amp;sid=${system.id}&amp;probe_id=${probe.id}"><img src="/img/csv-16.png" alt=""><bean:message key="listdisplay.csv"/></a>
  </c:if>
  <c:if test="${requestScope.show_log}">
    <h2><bean:message key="probedetails.jsp.eventlog"/></h2>
<rl:listset name="probeSet">
<!-- Start of active probes list -->
<rl:list width="100%"
         emptykey="probedetails.jsp.noevents">
	<!-- Timestamp column -->
	<rl:column bound="true"
			   attr="entryDate"
	           headerkey="probedetails.jsp.timestamp"
	           styleclass="first-column"/>
	<!-- state column -->
	<rl:column bound="true"
			   attr="state"
	           headerkey="probedetails.jsp.state"/>
	<!-- message column -->
	<rl:column bound="true"
			   attr="htmlifiedMessage"
	           headerkey="probedetails.jsp.message"
	           styleclass="last-column"/>
</rl:list>
<rl:csv	exportColumns="entryDate,state,message"/>
</rl:listset>
  </c:if>
  <c:if test="${requestScope.show_graph  ne true && requestScope.show_log ne true}">
    <bean:message key="probedetails.jsp.noselection"/>
  </c:if>
</body>
</html>
