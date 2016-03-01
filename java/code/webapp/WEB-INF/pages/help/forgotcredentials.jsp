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
  <rhn:toolbar base="h1" icon="header-search"
               helpUrl="">
    <bean:message key="help.credentials.jsp.logininfo"/>
  </rhn:toolbar>

  <h2><bean:message key="help.credentials.jsp.passwordreset"/></h2>

  <p><bean:message key="help.credentials.jsp.passwordtip"/></p>

  <html:form action="/help/ForgotCredentials.do">
    <rhn:csrf />
    <div class="search-choices panel panel-default">
      <div class="search-choices-group panel-body">
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <label for="searchform"><bean:message key="help.credentials.jsp.logininput"/></label>
          </div>
          <div class="col-md-4">
            <input type="text" name="username" accesskey="4" value="${username}" class="form-control">
          </div>
        </div>
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <label><bean:message key="help.credentials.jsp.emailinput"/></label>
          </div>
          <div class="col-md-4">
            <input type="text" name="email" accesskey="4" value="${email}" class="form-control">
          </div>
        </div>
        <div class="form-group">
          <div class="col-md-offset-2 col-md-10">
           <button type="submit" class="btn btn-success btn-sm" name="password_button">
             <bean:message key="help.credentials.jsp.passwordbutton"/>
          </button>
          </div>
        </div>
      </div>
    </div>

    <rhn:hidden name="submitted" value="true" />
  </html:form>

  <h2><bean:message key="help.credentials.jsp.logininfo"/></h2>

  <p><bean:message key="help.credentials.jsp.loginstip"/></p>

  <html:form action="/help/ForgotCredentials.do">
    <rhn:csrf />
    <div class="search-choices panel panel-default">
      <div class="search-choices-group panel-body">
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <label><bean:message key="help.credentials.jsp.emailinput"/></label>
          </div>
          <div class="col-md-4">
            <input type="text" name="email" accesskey="4" value="${email}" class="form-control">
          </div>
        </div>
        <div class="form-group">
          <div class="col-md-offset-2 col-md-10">
           <button type="submit" class="btn btn-success btn-sm" name="login_button">
             <bean:message key="help.credentials.jsp.loginbutton"/>
          </button>
          </div>
        </div>
      </div>
    </div>

    <rhn:hidden name="submitted" value="true" />
  </html:form>

</body>
</html>
