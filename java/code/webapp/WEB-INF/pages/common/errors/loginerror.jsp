<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>

<h1><img src="/img/rhn-icon-warning.gif"/><bean:message key="login.jsp.error.header"/></h1>

    <p><bean:message key="login.jsp.error.message"/></p>

    <c:if test="${loggedInUser != null}">
        <p><bean:message key="login.jsp.error.currentlyLoggedInAs" arg0="${loggedInUser}"/></p>
    </c:if>

</body>
</html>
