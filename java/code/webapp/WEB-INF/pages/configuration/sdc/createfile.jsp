<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-configuration">
  <bean:message key="sdccreatefile.jsp.header"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="sdccreatefile.jsp.summary"/>
    </p>
  </div>

  <div class="createfragment">
    <html:form styleClass="form-horizontal" action="/systems/details/configuration/addfiles/CreateFile.do?sid=${system.id}">
      <rhn:csrf />
      <rhn:submitted />
      <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/create.jspf" %>
    </html:form>
  </div>
</body>
</html>
