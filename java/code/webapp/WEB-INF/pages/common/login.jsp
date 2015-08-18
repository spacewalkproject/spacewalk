<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html>
<head>
    <meta name="decorator" content="layout_c" />
    <script src="/javascript/spacewalk-login.js"></script>
</head>
<body>

<c:if test="${schemaUpgradeRequired == 'true'}">
    <div class="alert alert-danger">
        <bean:message key="login.jsp.schemaupgraderequired" />
    </div>
</c:if>

<div class="text-center">
    <c:set var="login_banner" scope="page" value="${rhn:getConfig('java.login_banner')}" />
    <c:choose>
        <c:when test="${! empty login_banner}">
            <p>
                <c:out value="${login_banner}" escapeXml="false" />
            </p>
        </c:when>
        <c:otherwise>
            <h1>
                <bean:message key="login.jsp.welcomemessage" />
            </h1>
            <p>
                <bean:message key="login.jsp.satbody1" />
            </p>
        </c:otherwise>
    </c:choose>

    <html:form styleId="loginForm" styleClass="form-horizontal col-md-6 col-md-offset-3 text-left" action="/LoginSubmit">
        <rhn:csrf />
        <%@ include file="/WEB-INF/pages/common/fragments/login_form.jspf"%>
    </html:form>
    <div class="col-md-6 col-md-offset-3 text-left">
        <c:set var="legal_note" scope="page" value="${rhn:getConfig('java.legal_note')}" />
        <c:choose>
            <c:when test="${! empty legal_note}">
                <p>
                    <c:out value="${legal_note}" escapeXml="false" />
                </p>
            </c:when>
            <c:otherwise>
                <p>
                    <bean:message key="login.jsp.satbody2" />
                </p>
                <p>
                    <bean:message key="login.jsp.satbody3" />
                </p>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>
