<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
<script type="text/javascript" src="/javascript/highlander.js"></script>
</head>
<body>
  <rhn:toolbar base="h1" img="header-search"
               helpUrl="">
    <bean:message key="help.credentials.jsp.logininfo"/>
  </rhn:toolbar>

  <h2><bean:message key="help.credentials.jsp.passwordreset"/></h2>

  <p><bean:message key="help.credentials.jsp.passwordtip"/></p>

  <html:form action="/help/ForgotCredentials.do">
  <rhn:csrf />
    <table class="details">
      <tr><th><bean:message key="help.credentials.jsp.logininput"/></th>
      <td>
        <html:text property="username" name="username" value="${username}" />
      </td>
      </tr>
      <tr><th><bean:message key="help.credentials.jsp.emailinput"/></th>
      <td>
        <html:text property="email" name="email" value="${email}" />
      </td>
      </tr>
    </table>
    <div align="right">
      <hr />
      <html:submit property="password_button">
        <bean:message key="help.credentials.jsp.passwordbutton"/>
      </html:submit>
    </div>

    <input type="hidden" name="submitted" value="true" />
  </html:form>

  <h2><bean:message key="help.credentials.jsp.logininfo"/></h2>

  <p><bean:message key="help.credentials.jsp.loginstip"/></p>

  <html:form action="/help/ForgotCredentials.do">
  <rhn:csrf />
    <table class="details">
      <tr><th><bean:message key="help.credentials.jsp.emailinput"/></th>
      <td>
        <html:text property="email" name="email" value="${email}" />
      </td>
      </tr>
    </table>
    <div align="right">
      <hr />
      <html:submit property="login_button">
        <bean:message key="help.credentials.jsp.loginbutton"/>
      </html:submit>
    </div>

    <input type="hidden" name="submitted" value="true" />
  </html:form>

</body>
</html>
