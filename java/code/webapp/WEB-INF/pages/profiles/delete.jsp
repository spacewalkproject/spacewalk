<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/profile/header.jspf" %>

<h2><bean:message key="deleteconfirm.jsp.confirmprofiledeletion"/></h2>

<div class="page-summary">
   <p><bean:message key="deleteconfirm.jsp.profile_pagesummary" arg0="${requestScope.profile.name}"/></p>
</div>

<html:form action="/profiles/Delete">
      <rhn:csrf />
      <div class="text-right">
        <hr />
        <html:hidden property="prid" value="${param.prid}" />
        <html:hidden property="submitted" value="true" />
        <html:submit styleClass="btn btn-success">
	        <bean:message key="deleteconfirm.jsp.deleteprofile"/>
	    </html:submit>
      </div>
</html:form>

</body>
</html>

