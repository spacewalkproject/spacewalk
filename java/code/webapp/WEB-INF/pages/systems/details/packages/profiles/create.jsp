<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
<h2><bean:message key="create.jsp.createstoredprofile"/></h2>

<div class="page-summary">
   <p><bean:message key="create.jsp.pagesummary"/></p>
</div>

<html:form action="/systems/details/packages/profiles/Create">
      <rhn:csrf />
      <table class="details" align="center">
        <tr>
          <th><bean:message key="create.jsp.profilename" />:</th>
          <td><html:text property="name" maxlength="128" size="48" /></td>
        </tr>
        <tr>
          <th valign="top"><bean:message key="create.jsp.profiledescription" />:</th>

          <td><html:textarea property="description" cols="48" rows="6" /></td>
        </tr>
      </table>

      <div class="text-right">
        <hr />
        <html:hidden property="sid" value="${param.sid}" />
        <html:hidden property="submitted" value="true" />
        <html:submit>
	        <bean:message key="create.jsp.createprofile"/>
	    </html:submit>
      </div>
</html:form>

</body>
</html>
