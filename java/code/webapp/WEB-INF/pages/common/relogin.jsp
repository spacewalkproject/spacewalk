<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html>
<head>
  <script src="/javascript/spacewalk-login.js"></script>
</head>
<body>

<c:if test="${schemaUpgradeRequired == 'true'}">
    <div class="alert alert-danger">
        <bean:message key="login.jsp.schemaupgraderequired" />
    </div>
</c:if>

<rhn:require acl="not user_authenticated()">
  <c:if test="${requestScope.hasExpired != 'true'}">
    <div class="text-center">
      <h1><bean:message key="relogin.jsp.pleasesignin"/></h1>
      <c:set var="login_banner" scope="page" value="${rhn:getConfig('java.login_banner')}" />
      <c:if test="${! empty login_banner}">
        <p><c:out value="${login_banner}" escapeXml="false" /></p>
      </c:if>
      <html:form styleId="loginForm" styleClass="form-horizontal col-md-6 col-md-offset-3 text-left" action="/ReLoginSubmit">
        <rhn:csrf />
        <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf" %>
      </html:form>

      <c:set var="legal_note" scope="page" value="${rhn:getConfig('java.legal_note')}" />
      <c:if test="${! empty legal_note}">
        <p class="legal-note">
          <small><c:out value="${legal_note}" escapeXml="false" /></small>
        </p>
      </c:if>
    </div>
  </c:if>
</rhn:require>

</body>
</html>
