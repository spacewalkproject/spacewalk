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

<rhn:toolbar base="h2" img="/img/rhn-icon-system.gif">
 <bean:message key="probeedit.jsp.editprobe" />
</rhn:toolbar>
<html:form action="/systems/details/probes/ProbeCreate" method="POST">
  <c:set var="withSatCluster" value="true"/>
  <%@ include file="/WEB-INF/pages/common/fragments/probes/create-form-body.jspf" %>
  <html:hidden property="sid" value="${param.sid}"/>
</html:form>

</body>
</html>
