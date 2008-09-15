<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>

<h2><bean:message key="disableuser.jsp.confirm"/></h2>

<div class="page-summary">
<p>
    <bean:message key="disableuser.jsp.body"/>
</p>
</div>

<form method="POST" action="/rhn/users/DisableUserSubmit.do?uid=${param.uid}">
<div align="right">
      <hr />
      <html:submit>
          <bean:message key="disableuser.jsp.disable"/>
      </html:submit>
    </div>
</form>

</body>
</html>
