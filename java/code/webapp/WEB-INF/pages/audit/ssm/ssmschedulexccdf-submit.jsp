<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"     prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"     prefix="html"%>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2><bean:message key="system.audit.schedulexccdf.jsp.schedule"/></h2>

<div>
<html:form method="post" action="/systems/ssm/audit/ScheduleXccdfConfirm.do">

  <%@ include file="/WEB-INF/pages/common/fragments/audit/schedule-xccdf.jspf" %>

</html:form>
</div>

</body>
</html>
