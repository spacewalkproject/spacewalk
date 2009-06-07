<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>

<html:errors/>
<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="deleteconfirm.jsp.confirmprofiledeletion"/></h2>

<div class="page-summary">
   <p><bean:message key="deleteconfirm.jsp.profile_pagesummary" arg0="${requestScope.profile.name}"/></p>
</div>

<html:form action="/systems/details/packages/profiles/DeleteProfile">
      <div align="right">
        <hr />
        <html:hidden property="sid" value="${param.sid}" />
        <html:hidden property="prid" value="${param.prid}" />
        <html:hidden property="submitted" value="true" />
        <html:submit>
	        <bean:message key="deleteconfirm.jsp.deleteprofile"/>
	    </html:submit>
      </div>
</html:form>

</body>
</html
