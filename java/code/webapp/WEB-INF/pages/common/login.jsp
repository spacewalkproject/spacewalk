<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html>
<head>
  <meta name="decorator" content="layout_c" />
  <script src="/javascript/focus.js"></script>
  <script src="/javascript/spacewalk-login.js"></script>
</head>
<body onLoad="formFocus('loginForm', 'username');">

<c:if test="${schemaUpgradeRequired == 'true'}">
    <div class="site-alert">
        <bean:message key="login.jsp.schemaupgraderequired" />
    </div>
</c:if>

<c:if test="${requestScope.hasExpired != 'true'}">
  <div class="text-center">
    <c:set var="login_banner" scope="page" value="${rhn:getConfig('java.login_banner')}" />
    <c:choose>
      <c:when test="${! empty login_banner}">
        <p><c:out value="${login_banner}" escapeXml="false" /></p>
      </c:when>
      <c:otherwise>
        <h1>Welcome to Spacewalk</h1>
        <p><bean:message key="login.jsp.satbody1" /></p>
      </c:otherwise>
    </c:choose>

    <html:form styleId="loginForm" styleClass="form-horizontal col-md-6 col-md-offset-3 text-left" action="/LoginSubmit">
      <rhn:csrf />
      <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf" %>
    </html:form>

    <c:if test="${empty login_banner}">
        <div class="col-md-6 col-md-offset-3 text-left">
          <p><bean:message key="login.jsp.satbody2" /></p>
          <p><bean:message key="login.jsp.satbody3"/></p>
        </div>
    </c:if>
  </div>
</c:if>

</body>
</html>
