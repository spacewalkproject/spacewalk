<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean"     prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"     prefix="html"%>


<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2><bean:message key="system.audit.schedulexccdf.jsp.schedule"/></h2>
        <html:form method="post" styleClass="form-horizontal" action="/systems/ssm/audit/ScheduleXccdf.do">
            <%@ include file="/WEB-INF/pages/common/fragments/audit/schedule-xccdf.jspf" %>
            <div class="form-group">
                <div class="col-md-offset-3 col-md-6">
                    <html:submit property="schedule_button" styleClass="btn btn-success">
                        <bean:message key="system.audit.schedulexccdf.jsp.button"/>
                    </html:submit>
                </div>
            </div>
        </html:form>
        <%@ include file="/WEB-INF/pages/common/fragments/audit/scapcap-list.jspf" %>
    </body>
</html>
