<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
<body>

  <rhn:toolbar base="h1" img="/img/rhn-config_management.gif"
               helpUrl="/rhn/help/reference/en-US/s2-sm-monitor-psuites.jsp">
    <bean:message key="probe-create.jsp.header1" arg0="${probeSuite.suiteName}" />
  </rhn:toolbar>

<h2><bean:message key="probe-create.jsp.header2"/></h2>

<html:errors />
<html:form action="/monitoring/config/ProbeSuiteProbeCreate" method="POST">
    <c:set var="withSatCluster" value="false"/>
    <%@ include file="/WEB-INF/pages/common/fragments/probes/create-form-body.jspf" %>
  <html:hidden property="suite_id" value="${param.suite_id}"/>
</html:form>
           
</body>
</html>
