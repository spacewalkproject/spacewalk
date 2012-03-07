<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="system.audit.schedulexccdf.jsp.schedule"/></h2>

<c:choose>
	<c:when test="${not requestScope.scapEnabled}">
		<p><bean:message key="system.audit.listscap.jsp.missing"
			arg0="spacewalk-openscap"/></p>
	</c:when>
	<c:otherwise>
		<html:form method="post" action="/systems/details/audit/ScheduleXccdf.do">
		<rhn:csrf/>
		<table class="details">
		<tr>
			<th><bean:message key="system.audit.schedulexccdf.jsp.command"/>:</th>
			<td>/usr/bin/oscap xccdf eval</td>
		</tr>
		<tr>
			<th><bean:message key="system.audit.schedulexccdf.jsp.arguments"/>:</th>
			<td><html:text property="params" maxlength="2048" size="40" styleId="params"/></td>
		</tr>
		<tr>
			<th><bean:message key="system.audit.schedulexccdf.jsp.path"/><span class="required-form-field">*</span>:</th>
			<td><html:text property="path" size="40" styleId="path"/></td>
		</tr>
		<tr>
			<th><bean:message key="scheduleremote.jsp.nosoonerthan"/>:</th>
			<td>
				<jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
					<jsp:param name="widget" value="date"/>
				</jsp:include>
			</td>
		</tr>
		</table>

		<html:hidden property="sid" value="${param.sid}"/>
		<html:hidden property="submitted" value="true" />

		<div align="right">
			</hr>
			<html:submit property="schedule_button">
				<bean:message key="system.audit.schedulexccdf.jsp.button"/>
			</html:submit>
		</div>
		</html:form>
		<rhn:tooltip>
			<bean:message key="system.audit.schedulexccdf.jsp.tooltip"/>
		</rhn:tooltip>
	</c:otherwise>
</c:choose>

</body>
</html>
