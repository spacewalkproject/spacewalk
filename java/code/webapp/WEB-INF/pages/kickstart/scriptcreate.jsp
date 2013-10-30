<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<head>
<%@ include file="/WEB-INF/pages/common/fragments/editarea.jspf" %>
</head>

<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstart.script.header1"/></h2>

<div>
  <p>
    <bean:message key="kickstart.script.summary"/>
  </p>
    <html:form method="post" action="/kickstart/KickstartScriptCreate.do">
      <rhn:csrf />
      <%@ include file="script-form.jspf" %>
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
    </html:form>
</div>

</body>
</html:html>

