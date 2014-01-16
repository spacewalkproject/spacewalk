<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2><bean:message key="system.audit.schedulexccdf.jsp.schedule"/></h2>
    <c:choose>
        <c:when test="${not requestScope.scapEnabled}">
            <p><bean:message key="system.audit.listscap.jsp.missing" arg0="${requiredPackage}"/></p>
        </c:when>
        <c:otherwise>
            <html:form method="post" styleClass="form-horizontal" action="/systems/details/audit/ScheduleXccdf.do">
                <%@ include file="/WEB-INF/pages/common/fragments/audit/schedule-xccdf.jspf" %>
                <html:hidden property="sid" value="${param.sid}"/>
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-6">
                        <html:submit property="schedule_button" styleClass="btn btn-success">
                            <bean:message key="system.audit.schedulexccdf.jsp.button"/>
                        </html:submit>
                    </div>
                </div>
            </html:form>
        </c:otherwise>
    </c:choose>
</body>
</html>
