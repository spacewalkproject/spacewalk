<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">
<head>
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
<html:form action="/users/UserDetailsSubmit?uid=${user.id}">

 <h2><bean:message key="userdetails.jsp.header"/></h2>
 <div class="page-summary">
 <p>
 <bean:message key="userdetails.jsp.summary"/>
 </p>
 </div>

 <table class="details" align="center">

  <%@ include file="/WEB-INF/pages/common/fragments/user/edit_user_table_rows.jspf"%>

  <tr>
    <th><bean:message key="userdetails.jsp.adminRoles"/>:</th>
    <td>

        <c:forEach items="${adminRoles}" var="role">
            <input type="checkbox" name="role_${role.value}" <c:if test="${role.selected}">checked="true"</c:if> <c:if test="${role.disabled}">disabled="true"</c:if>/> ${role.name}<br/>
        </c:forEach>

    </td>
  </tr>
  <tr>
    <th><bean:message key="userdetails.jsp.roles"/>:</th>
    <td>

        <c:forEach items="${regularRoles}" var="role">
            <input type="checkbox" name="role_${role.value}" <c:if test="${role.selected}">checked="true"</c:if> <c:if test="${role.disabled}">disabled="true"</c:if>/> ${role.name}<br/>
        </c:forEach>

        <c:if test="${orgAdmin}">
            <p/>
            <em><bean:message key="userdetails.jsp.grantedByOrgAdmin"/></em>
        </c:if>

    </td>
  </tr>
  <tr>
    <th><bean:message key="created.displayname"/></th>
    <td>${created}</td>
  </tr>

  <tr>
    <th><bean:message key="last_sign_in.displayname"/></th>
    <td>${lastLoggedIn}</td>
  </tr>

 </table>

 <input type="hidden" name="disabledRoles" value="${disabledRoles}"/>

 <c:if test="${!empty mailableAddress}">
 <div align="right">
   <hr />
   <html:submit />
 </div>
 </c:if>

</html:form>

</body>
</html:html>
