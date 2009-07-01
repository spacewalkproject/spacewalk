<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2><bean:message key="ssm.kickstartable-systems.jsp.title"/></h2>
  <div class="page-summary">
    <p>
    <bean:message key="ssm.kickstartable-systems.jsp.summary"/>
    </p>
  </div>

<br />
<h2>
  <img src="/img/icon_kickstart_session-medium.gif"
       alt="<bean:message key='system.common.kickstartAlt' />" />
  <bean:message key="kickstart.schedule.heading1.jsp" />
</h2>

    <div class="page-summary">
    <p>
        <bean:message key="ssm.kickstart.schedule.heading1.text.jsp" />
    </p>
    <h2><bean:message key="kickstart.schedule.heading2.jsp" /></h2>
    </div>

    <div class="page-summary">
    <p>
        <bean:message key="ssm.kickstart.schedule.heading2.text.jsp" />
    </p>
    </div>
<rl:listset name="form">
		<c:if test="${empty requestScope.isIP}">
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/profile-list.jspf" %>
		</c:if>
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/proxy-options.jspf" %>
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/schedule-options.jspf" %>
<div align="right">
<hr />
<input type="submit" name="dispatch" value="${rhn:localize('kickstart.schedule.button2.jsp')}"/>
</div>
		
<rhn:submitted/>
</rl:listset>


</body>
</html>
