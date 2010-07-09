<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" img="/img/rhn-icon-system.gif" >
  <bean:message key="sdcdeployconfirm.jsp.header"
                arg0="${system.name}"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="sdcdeployconfirm.jsp.summary"
                  arg0="${system.name}"/>
    </p>
  </div>

<html:form method="post"
		action="/systems/details/configuration/DeployFileConfirmSubmit.do?sid=${system.id}">
    <c:set var="button" value="sdcdeployconfirm.jsp.schedule" />
    <%@ include file="/WEB-INF/pages/common/fragments/configuration/sdc/configfile_confirm.jspf" %>
</html:form>

</body>
</html>