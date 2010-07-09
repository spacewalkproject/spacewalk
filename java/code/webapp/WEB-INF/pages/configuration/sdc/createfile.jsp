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

<h2><bean:message key="sdccreatefile.jsp.header"/></h2>

  <div class="page-summary">
    <p>
    <bean:message key="sdccreatefile.jsp.summary"/>
    </p>
  </div>

  <div class="createfragment">
    <html:form action="/systems/details/configuration/addfiles/CreateFile.do?sid=${system.id}">
      <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/create.jspf" %>
    </html:form>
  </div>
</body>
</html>