<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2"
             icon="fa-desktop"
             imgAlt="system.common.systemAlt">
  <bean:message key="sdcdeployfile.jsp.header"
                arg0="${system.name}"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="sdcdeployfile.jsp.summary"
                  arg0="${system.name}"/>
    </p>
  </div>

<form method="post" name="rhn_list"
		action="/rhn/systems/details/configuration/DeployFileSubmit.do?sid=${system.id}">
    <rhn:csrf />
    <c:set var="button" value="sdcdeployfile.jsp.confirm" />
    <%@ include file="/WEB-INF/pages/common/fragments/configuration/sdc/configfile_list.jspf" %>
</form>

</body>
</html>
