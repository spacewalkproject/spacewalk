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

<rhn:toolbar base="h2"
             img="/img/rhn-icon-system.gif"
             imgAlt="system.common.systemAlt">
  <bean:message key="sdcdifffile.jsp.header"
                arg0="${system.name}"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="sdcdifffile.jsp.summary"
                  arg0="${system.name}"/>
    </p>
  </div>

<form method="post"
		name="rhn_list"
		action="/rhn/systems/details/configuration/DiffFileSubmit.do?sid=${system.id}">
    <c:set var="button" value="sdcdifffile.jsp.confirm" />
    <%@ include file="/WEB-INF/pages/common/fragments/configuration/sdc/configfile_list.jspf" %>
</form>

</body>
</html>