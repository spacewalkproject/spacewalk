<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html:xhtml/>
<html>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif" imgAlt="users.jsp.imgAlt"
    helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-account">
  <bean:message key="credentials.jsp.delete.dispatch" />
</rhn:toolbar>

<div class="page-summary">
  <p><bean:message key="credentials.jsp.delete.summary" /></p>
</div>

<hr />

<h2><bean:message key="credentials.jsp.susestudio" /></h2>
<table class="details">
<tr>
  <th><bean:message key="credentials.jsp.username" /></th>
  <td><c:out value="${creds.username}" /></td>
</tr>
<tr>
  <th><bean:message key="credentials.jsp.apikey" /></th>
  <td><c:out value="${creds.password}" /></td>
</tr>
<tr>
  <th><bean:message key="credentials.jsp.url" /></th>
  <td><c:out value="${creds.url}" /></td>
</tr>
</table>

<form method="post" action="/rhn/account/DeleteCredentials.do">
  <rhn:csrf />
  <rhn:submitted />
  <div align="right">
    <hr />
    <html:submit property="dispatch">
      <bean:message key="credentials.jsp.delete.dispatch" />
    </html:submit>
  </div>
</form>

</body>
</html>
