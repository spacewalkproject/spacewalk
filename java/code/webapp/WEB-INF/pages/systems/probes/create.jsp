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
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <rhn:toolbar base="h2" icon="fa-desktop">
            <bean:message key="probeedit.jsp.editprobe" />
        </rhn:toolbar>
        <html:form action="/systems/details/probes/ProbeCreate" method="POST" styleClass="form-horizontal">
            <rhn:csrf />
            <c:set var="withSatCluster" value="true"/>
            <%@ include file="/WEB-INF/pages/common/fragments/probes/create-form-body.jspf" %>
            <html:hidden property="sid" value="${param.sid}"/>
        </html:form>
    </body>
</html>
