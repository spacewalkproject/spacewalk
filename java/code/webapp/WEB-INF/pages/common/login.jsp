<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html>
<head>
    <script src="/javascript/focus.js" type="text/javascript"></script>
    <meta name="decorator" content="layout_c" />
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

<c:if test="${requestScope.hasExpired != 'true'}">
  <div class="text-center">
    <h1>Welcome to Spacewalk</h1>
    <p><bean:message key="login.jsp.satbody1" /></p>
    <html:form styleId="loginForm" styleClass="form-horizontal col-md-6 col-md-offset-3 text-left" action="/LoginSubmit">
      <rhn:csrf />
      <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf" %>
    </html:form>
    <div class="col-md-6 col-md-offset-3 text-left">
      <p><bean:message key="login.jsp.satbody2" /></p>
      <p><bean:message key="login.jsp.satbody3"/></p>
    </div>
  </div>
</c:if>

</body>
</html>
