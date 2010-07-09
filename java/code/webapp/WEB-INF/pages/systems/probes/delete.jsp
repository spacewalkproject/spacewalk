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

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="probdelete.jsp.header"/></h2>
<html:form action="/systems/details/probes/ProbeDelete" method="POST">

    <p><bean:message key="probdelete.jsp.p1"/></p>

    <p><strong><bean:message key="probdelete.jsp.p2" arg0="${probe.id}" arg1="${system.id}"/>
    </strong></p>

    <p><bean:message key="probdelete.jsp.p3"/></p>

    <p><strong><bean:message key="probdelete.jsp.p4"/></strong></p>

    <div align="right">
    <hr />
        <html:submit><bean:message key="probdelete.jsp.deleteprobe"/></html:submit></td>

        <html:hidden property="sid" value="${param.sid}"/>
        <html:hidden property="probe_id" value="${probe.id}"/>
        <html:hidden property="submitted" value="true"/>
    </div>
</html:form>

</body>
</html>
