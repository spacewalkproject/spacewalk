<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

<rhn:toolbar base="h1" icon="icon-user" imgAlt="users.jsp.imgAlt">
    <c:out escapeXml="true" value="${targetuser.login}" />
</rhn:toolbar>


<h2><bean:message key="deleteuser.jsp.confirm"/></h2>

<div class="page-summary">
    <bean:message key="deleteuser.jsp.body"/>
</div>

<form method="POST" action="/rhn/users/DeleteUserSubmit.do?uid=${param.uid}">
<rhn:csrf />
<div align="right">
      <hr />
      <html:submit>
          <bean:message key="deleteuser.jsp.delete"/>
      </html:submit>
    </div>
</form>

</body>
</html>
