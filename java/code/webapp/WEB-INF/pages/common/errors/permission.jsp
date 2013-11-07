<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>

<h1>
  <i class="fa fa-warning text-warning" title="<bean:message key='error.common.errorAlt' />"></i>
  ${error.localizedTitle}
</h1>

<p>${error.localizedSummary}</p>

</body>
</html>