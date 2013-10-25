<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="User Details" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>

<h2><bean:message key="enableuser.jsp.confirm"/></h2>

<div class="page-summary">
    <bean:message key="enableuser.jsp.body"/>
</div>

<form method="POST" action="/rhn/users/EnableUserSubmit.do?uid=${param.uid}">
<rhn:csrf />
<div class="text-right">
      <hr />
      <html:submit>
          <bean:message key="enableuser.jsp.enable"/>
      </html:submit>
    </div>
</form>

</body>
</html>
