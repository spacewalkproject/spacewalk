<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html:xhtml/>
<html>
<head>
    <script src="/javascript/focus.js" type="text/javascript"></script>
    <meta name="decorator" content="layout_equals" />
</head>
<body onLoad="formFocus('loginForm', 'username')">

<c:if test="${schemaUpgradeRequired == 'true'}">
    <div class="site-alert">
        <bean:message key="login.jsp.schemaupgraderequired" />
    </div>
</c:if>

<c:if test="${requestScope.hasExpired != 'true'}">
<div id="contentLeft">
  <div class="clearBox">
  <div class="clearBoxInner">
  <div class="clearBoxBody">

    <html:form action="/LoginSubmit">
        <rhn:csrf />
        <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf" %>
    </html:form>
  </div>
  </div>
  </div>
</div> <!-- end contentLeft -->
</c:if>

<div id="contentRight">
  <c:set var="login_banner" scope="page" value="${rhn:getConfig('java.login_banner')}" />
  <c:choose>
    <c:when test="${! empty login_banner}">
      <p><c:out value="${login_banner}" escapeXml="false"/></p>
    </c:when>
    <c:otherwise>
      <h1 id="rhn_welcome3"><span><bean:message key="login.jsp.welcomemessage"/></span></h1>

      <p><bean:message key="login.jsp.satbody1"/></p>
      <p><bean:message key="login.jsp.satbody2"/></p>
      <p><bean:message key="login.jsp.satbody3"/></p>
      <p><bean:message key="login.jsp.satbody4"/></p>
    </c:otherwise>
  </c:choose>
</div> <!-- end contentRight -->
</body>
</html>
