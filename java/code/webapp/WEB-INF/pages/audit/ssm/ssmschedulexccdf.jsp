<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean"     prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"     prefix="html"%>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2><bean:message key="system.audit.schedulexccdf.jsp.schedule"/></h2>

<div>
<html:form method="post" action="/systems/ssm/audit/ScheduleXccdf.do">

  <%@ include file="/WEB-INF/pages/common/fragments/audit/schedule-xccdf.jspf" %>
  <rhn:tooltip><bean:message key="system.audit.schedulexccdf.jsp.tooltip"/></rhn:tooltip>
  <div align="right">
    </hr>
    <html:submit property="schedule_button">
      <bean:message key="system.audit.schedulexccdf.jsp.button"/>
    </html:submit>
  </div>
</html:form>

<%@ include file="/WEB-INF/pages/common/fragments/audit/scapcap-list.jspf" %>
</div>

</body>
</html>
