<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<head>
  <script src="/javascript/focus.js" type="text/javascript"></script>
  <script>
    // Remove the aside to center the login
    function setupLogin() {
      $$("aside").invoke("remove");
      $$("section").invoke("removeClassName", "col-md-10");
      $$("section").invoke("addClassName", "col-md-8 col-md-offset-2");
    }
  </script>
</head>
<body onLoad="formFocus('loginForm', 'username');setupLogin();">

<c:if test="${schemaUpgradeRequired == 'true'}">
    <div class="site-alert">
        <bean:message key="login.jsp.schemaupgraderequired" />
    </div>
</c:if>

<rhn:require acl="not user_authenticated()">
  <c:if test="${requestScope.hasExpired != 'true'}">
    <div class="text-center">
      <h1><bean:message key="relogin.jsp.pleasesignin"/></h1>
      <html:form styleId="loginForm" styleClass="form-horizontal col-md-6 col-md-offset-3 text-left" action="/ReLoginSubmit">
        <rhn:csrf />
        <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf" %>
        <html:hidden property="url_bounce" />
        <html:hidden property="request_method" />
      </html:form>
    </div>
  </c:if>
</rhn:require>

</body>
</html>
