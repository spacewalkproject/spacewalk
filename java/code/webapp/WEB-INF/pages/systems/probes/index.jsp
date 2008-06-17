<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml/>
<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" img="/img/rhn-icon-system.gif" helpUrl="/rhn/help/reference/en/s2-sm-system-list.jsp#s4-sm-system-details-probes" 
    creationUrl="/rhn/systems/details/probes/ProbeCreate.do?sid=${system.id}" 
    creationType="probe" >
<bean:message key="probes.index.jsp.toolbar"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="probes.index.jsp.summary"/>
    </p>
  </div>

<rhn:list pageList="${requestScope.pageList}" noDataText="probes.index.jsp.noprobes" legend="probes-list">
  <rhn:listdisplay set="${requestScope.set}" exportColumns="id,description,stateString,stateOutputString" 
        hiddenvars="${requestScope.newset}">
    <%@ include file="/WEB-INF/pages/common/fragments/probes/probe-state-column.jspf" %>
    <rhn:column header="probes.index.jsp.description" nowrap="nowrap">
      <a href="ProbeDetails.do?probe_id=${current.id}&sid=${system.id}">${current.description}</A>
    </rhn:column>
    <rhn:column header="probes.index.jsp.status" sortProperty="stateOutputString">  
      ${current.stateOutputString}
    </rhn:column>
    <rhn:column header="probes.index.jsp.type">
        <c:if test="${current.isSuiteProbe}">
          <a title='<bean:message key="probes.index.jsp.suiteedit"/>' href="/rhn/monitoring/config/ProbeSuiteProbeEdit.do?suite_id=${current.probeSuiteId}&probe_id=${current.id}"><bean:message key="probes.index.jsp.suite"/></a>
        </c:if>
        <c:if test="${not current.isSuiteProbe}">
          <a title='<bean:message key="probes.index.jsp.systemedit"/>' href="ProbeEdit.do?probe_id=${current.id}&sid=${system.id}"><bean:message key="probes.index.jsp.system"/></a>
        </c:if>
    </rhn:column>
 </rhn:listdisplay>
</rhn:list>

           
</body>
</html>
