<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html:xhtml/>
<html>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif" imgAlt="users.jsp.imgAlt"
    helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-account"
    deletionUrl="/rhn/account/DeleteCredentials.do"
    deletionType="credentials">
  <bean:message key="Credentials"/>
</rhn:toolbar>

<div class="page-summary">
  <p><bean:message key="credentials.jsp.edit.summary" /></p>
</div>

<form method="post" action="/rhn/account/Credentials.do">
  <rhn:csrf />
  <rhn:submitted />

  <h2><bean:message key="credentials.jsp.susestudio" /></h2>
  <table class="details">
  <tr>
    <th><bean:message key="credentials.jsp.username" /></th>
    <td><html:text property="studio_user" value="${creds.username}" /></td>
  </tr>
  <tr>
    <th><bean:message key="credentials.jsp.apikey" /></th>
    <td><html:text property="studio_key" value="${creds.password}" /></td>
  </tr>
  <tr>
    <th><bean:message key="credentials.jsp.url" /></th>
    <td><html:text property="studio_url" value="${creds.url}" /></td>
  </tr>
  </table>

  <div align="right">
    <hr />
    <html:submit>
      <bean:message key="credentials.jsp.edit.dispatch" />
    </html:submit>
  </div>
</form>

</body>
</html>
