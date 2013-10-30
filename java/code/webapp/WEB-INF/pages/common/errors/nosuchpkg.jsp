<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>

<h1>
  <img src="/img/rhn-icon-warning.gif"
       alt="<bean:message key='error.common.errorAlt' />" />
  <bean:message key="unknown.package" />:
</h1>

<p><bean:message key="unknown.package.msg" /></p>

</body>
</html>
