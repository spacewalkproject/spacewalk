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
    <bean:message key="passwordreset.jsp.reset.password"/>
  </rhn:toolbar>

  <p><bean:message key="passwordreset.jsp.passwordtip"/></p>

  <html:form action="/ResetPasswordSubmit">
    <rhn:csrf />
    <div class="search-choices panel panel-default">
      <div class="search-choices-group panel-body">
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <label for="searchform"><bean:message key="password.displayname"/></label>
          </div>
          <div class="col-md-4">
            <input type="text" name="password" class="form-control">
          </div>
        </div>
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <label><bean:message key="confirmpass.displayname"/></label>
          </div>
          <div class="col-md-4">
            <input type="text" name="passwordConfirm" class="form-control">
          </div>
        </div>
        <div class="form-group">
          <div class="col-md-offset-2 col-md-10">
           <button type="submit" class="btn btn-success btn-sm" name="password_button">
             <bean:message key="passwordreset.jsp.update"/>
          </button>
          </div>
        </div>
      </div>
    </div>

    <input type="hidden" name="submitted" value="true" />
  </html:form>
