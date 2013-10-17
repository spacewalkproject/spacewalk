<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
</head>
<body>

<rhn:toolbar base="h1" icon="icon-search" imgAlt="search.alt.img">
  <bean:message key="scapdiff.jsp.toolbar"/>
</rhn:toolbar>

<p><bean:message key="scapdiff.jsp.summary"/></p>
<p><bean:message key="scapdiff.jsp.instructions"/></p>

<html:form method="get" action="/audit/scap/DiffSubmit.do">
  <rhn:csrf/>

  <table class="details">
    <tr>
      <th><bean:message key="xccdfdiff.firstscan"/>:</th>
      <td><html:text property="first"/></td>
    </tr>
    <tr>
      <th><bean:message key="xccdfdiff.secondscan"/>:</th>
      <td><html:text property="second"/>
        <html:submit><bean:message key="xccdfdiff.schedulescan"/></html:submit>
      </td>
  </table>
</html:form>
</body>
</html>

