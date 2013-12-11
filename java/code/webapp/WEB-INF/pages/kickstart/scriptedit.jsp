<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<head>
<%@ include file="/WEB-INF/pages/common/fragments/editarea.jspf" %>
</head>


<html>
<body>
<rhn:toolbar base="h1" icon="header-kickstart"
           deletionUrl="/rhn/kickstart/KickstartScriptDelete.do?kssid=${kssid}&ksid=${ksdata.id}"
           deletionType="kickstartscript" >
   <bean:message key="kickstartdetails.jsp.header1" arg0="${fn:escapeXml(ksdata.label)}"/>
</rhn:toolbar>
<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<p>
<h2><bean:message key="kickstart.script.header1"/></h2>

<div>
  <p>
    <bean:message key="kickstart.script.summary"/>
    <p>

    <html:form method="POST" action="/kickstart/KickstartScriptEdit.do">
      <rhn:csrf />
      <%@ include file="script-form.jspf" %>
      <html:hidden property="kssid" value="${kssid}"/>
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
    </html:form>
  </p>
</div>

</body>
</html>

