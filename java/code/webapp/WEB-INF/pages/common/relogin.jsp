<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<head>
  <script src="/javascript/focus.js" type="text/javascript"></script>
</head>
<body onLoad="formFocus('loginForm', 'username')">

<c:if test="${schemaUpgradeRequired == 'true'}">
    <div class="site-alert">
        <bean:message key="login.jsp.schemaupgraderequired" />
    </div>
</c:if>

<rhn:require acl="not user_authenticated()">
<c:if test="${requestScope.hasExpired != 'true'}">
     <h1><bean:message key="relogin.jsp.pleasesignin"/></h1>

  <div id="contentLeft">
    <div class="clearBox">
    <div class="clearBoxInner">
    <div class="clearBoxBody">
      <html:form action="/ReLoginSubmit">
          <rhn:csrf />
          <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf" %>
           <html:hidden property="url_bounce" />
           <html:hidden property="request_method" />
      </html:form>
    </div><!-- end clearBoxBody -->
    </div><!-- end clearBoxInner -->
    </div><!-- end clearBox -->
  </div> <!-- end contentLeft -->

  <div id="contentRight">
    <c:set var="login_banner" scope="page" value="${rhn:getConfig('java.login_banner')}" />
    <c:if test="${! empty login_banner}">
      <p><c:out value="${login_banner}" escapeXml="false"/></p>
    </c:if>
  </div> <!-- end contentRight -->
</c:if>
</rhn:require>

</body>
</html>
