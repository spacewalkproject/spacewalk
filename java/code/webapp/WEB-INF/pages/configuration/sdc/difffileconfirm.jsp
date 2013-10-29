<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="fa-desktop" >
  <bean:message key="sdcdiffconfirm.jsp.header"
                arg0="${fn:escapeXml(system.name)}"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="sdcdiffconfirm.jsp.summary"
                  arg0="${fn:escapeXml(system.name)}"/>
    </p>
  </div>

<html:form method="post"
		action="/systems/details/configuration/DiffFileConfirmSubmit.do?sid=${system.id}">
    <rhn:csrf />
    <c:set var="button" value="sdcdiffconfirm.jsp.schedule" />
    <%@ include file="/WEB-INF/pages/common/fragments/configuration/sdc/configfile_confirm.jspf" %>
</html:form>

</body>
</html>
