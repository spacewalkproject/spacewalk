<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>
<h2><bean:message key="deleteconfirm.jsp.confirmsatadminrole"/></h2>

<div class="page-summary">
   <p><bean:message key="deleteconfirm.jsp.satadmin.description"/></p>
   <p><bean:message key="deleteconfirm.jsp.satadmin_revoke" arg0="${requestScope.username}"/></p>
</div>

<html:form action="/admin/multiorg/SatRoleConfirm.do">
      <rhn:csrf />
      <div class="text-right">
        <hr />
        <html:hidden property="uid" value="${param.uid}" />
        <html:hidden property="submitted" value="true" />
        <html:submit>
	        <bean:message key="confirm.displayname"/>
	    </html:submit>
      </div>
</html:form>

</body>
</html
