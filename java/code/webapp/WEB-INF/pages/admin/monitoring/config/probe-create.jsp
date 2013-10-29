<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
    <body>
        <rhn:toolbar base="h1" icon="fa-cog"
                     helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-psuites">
            <bean:message key="probe-create.jsp.header1" arg0="${probeSuite.suiteName}" />
        </rhn:toolbar>

        <h2><bean:message key="probe-create.jsp.header2"/></h2>
        <html:form action="/monitoring/config/ProbeSuiteProbeCreate"
                   method="POST"
                   styleClass="form-horizontal">
            <rhn:csrf />
            <c:set var="withSatCluster" value="false"/>
            <%@ include file="/WEB-INF/pages/common/fragments/probes/create-form-body.jspf" %>
            <html:hidden property="suite_id" value="${param.suite_id}"/>
        </html:form>
    </body>
</html>
