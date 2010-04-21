<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif"
 helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-account"
 imgAlt="users.jsp.imgAlt">
 <bean:message key="details.jsp.account_details" />
</rhn:toolbar>
<div class="page-summary">
<p>
<bean:message key="yourdetails.jsp.summary" />
</p>

</div>
<h2><bean:message key="details.jsp.personal_info" /></h2>
<html:form action="/account/UserDetailsSubmit">

 <table class="details" align="center">

   <%@ include file="/WEB-INF/pages/common/fragments/user/edit_user_table_rows.jspf"%>
  <tr>
    <th><bean:message key="created.displayname"/></th>
    <td>${created}</td>
  </tr>

    <tr>
      <th><bean:message key="last_sign_in.displayname"/></th>
      <td>${lastLoggedIn}</td>
    </tr>

 </table>


 <html:hidden property="uid" />
 <c:if test="${!empty mailableAddress}">
 <div align="right">
   <hr />
   <rhn:submit valueKey="message.Update"/>
 </div>
 </c:if>

</html:form>

</body>
</html>
