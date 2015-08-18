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
    <div class="text-center">
        <h1>
            <bean:message key="relogin.jsp.pleasesignin" />
        </h1>
        <html:form styleId="loginForm" styleClass="form-horizontal col-md-6 col-md-offset-3 text-left" action="/ReLoginSubmit">
            <rhn:csrf />
            <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf"%>
        </html:form>
    </div>
</rhn:require>

</body>
</html>
