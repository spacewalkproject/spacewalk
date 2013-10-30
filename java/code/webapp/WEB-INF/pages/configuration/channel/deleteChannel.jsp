<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://struts.apache.org/tags-html"	prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"	prefix="bean"%>

<html:xhtml />

<html>
<body>

<%@ include	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<div class="panel panel-danger">
	<div class="panel-heading">
		<h4><bean:message key="channelOverview.jsp.deleteInstruction" /></h4>
	</div>
	<div class="panel-body">
		<html:form action="/configuration/DeleteChannel.do?ccid=${ccid}">
	    <rhn:csrf />
		<html:hidden property="submitted" value="true" />
		<table class="table">
			<tr>
				<th><bean:message key="channelOverview.jsp.name" /></th>
				<td><strong>${currChannel.name}</strong></td>
			</tr>
			<tr>
				<th><bean:message key="channelOverview.jsp.descr" /></th>
				<td><strong>${currChannel.description}</strong></td>
			</tr>
		</table>
		<div class="text-right">
		<hr />
		<html:submit styleClass="btn btn-danger">
			<bean:message key="channelOverview.jsp.deleteChannel" />
		</html:submit>
		</div>
	</html:form>
	</div>
</div>
</body>
</html>

