<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>

<h1><i class="fa fa-warning text-warning"></i><bean:message key="login.jsp.error.header"/></h1>

    <p><bean:message key="login.jsp.error.message"/></p>

    <c:if test="${loggedInUser != null}">
        <p><bean:message key="login.jsp.error.currentlyLoggedInAs" arg0="${loggedInUser}"/></p>
    </c:if>

</body>
</html>
