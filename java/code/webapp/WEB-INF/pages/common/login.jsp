<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html:xhtml/>
<html>
<head>
    <script src="/javascript/focus.js" type="text/javascript"></script>
    <meta name="decorator" content="layout_equals" />
</head>
<body onLoad="formFocus('loginForm', 'username')">
<c:if test="${requestScope.hasExpired != 'true'}">
<div id="contentLeft">
  <div class="clearBox">
  <div class="clearBoxInner">
  <div class="clearBoxBody">

    <html:form action="/LoginSubmit">
        <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf" %>
    </html:form>
  </div>
  </div>
  </div>
</div> <!-- end contentLeft -->
</c:if>

<div id="contentRight">
  <h1 id="rhn_welcome3"><span><bean:message key="login.jsp.welcomemessage"/></span></h1>

    <p><bean:message key="login.jsp.satbody1"/></p>
    <p><bean:message key="login.jsp.satbody2"/></p>
    <p><bean:message key="login.jsp.satbody3"/></p>
    <p><bean:message key="login.jsp.satbody4"/></p>


</div> <!-- end contentRight -->
</body>
</html>
