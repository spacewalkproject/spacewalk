<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html>
<head>
<script type="text/javascript" src="/javascript/highlander.js"></script>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/user/user_attribute_sizes.jspf"%>
  <rhn:toolbar base="h1" icon="header-search"
               helpUrl="">
    <bean:message key="passwordreset.jsp.header"/>
  </rhn:toolbar>
  <p><bean:message key="passwordreset.jsp.passwordtip" arg0="${passwordMinLength}" arg1="${passwordLength}"/></p>

  <html:form action="/ResetPasswordSubmit">
    <rhn:csrf />
    <html:hidden property="token" value="${param.token}" />
    <div class="search-choices panel panel-default">
      <div class="search-choices-group panel-body">
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <label for="searchform"><bean:message key="password.displayname"/></label>
          </div>
          <div class="col-md-4">
            <html:password property="password" styleClass="form-control" maxlength="${passwordLength}"/>
          </div>
        </div>
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <label><bean:message key="confirmpass.displayname"/></label>
          </div>
          <div class="col-md-4">
            <html:password property="passwordConfirm" styleClass="form-control" maxlength="${passwordLength}"/>
          </div>
        </div>
        <div class="form-group">
          <div class="col-md-offset-2 col-md-10">
           <html:submit styleClass="btn btn-success btn-sm">
             <bean:message key="passwordreset.jsp.update"/>
          </html:submit>
          </div>
        </div>
      </div>
    </div>

    <html:hidden property="submitted" value="true" />
  </html:form>
</body>
</html:html>