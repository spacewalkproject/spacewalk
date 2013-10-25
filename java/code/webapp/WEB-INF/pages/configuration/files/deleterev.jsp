<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"
	prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"
	prefix="html"%>

<html:xhtml/>
<html>
<head></head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf"%>

<h2><bean:message key="deleterev.jsp.header2" /></h2>
<bean:message key="deleterev.jsp.info" arg0="${channel.displayName}" arg1="/rhn/configuration/ChannelOverview.do?ccid=${ccid}"/>
<p />
<html:form action="/configuration/file/DeleteRevision.do?crid=${crid}&amp;cfid=${cfid}">
    <rhn:csrf />
	<html:hidden property="submitted" value="true"/>
	<table class="table">
	<tr>
		<th><bean:message key="deleterev.jsp.channelname" /></th>
		<td>${file.configChannel.displayName}</td>
	</tr>
	<tr>
		<th><bean:message key="deleterev.jsp.revisionpath" /></th>
		<td>${file.configFileName.path}</td>
	</tr>
	<tr>
		<th><bean:message key="deleterev.jsp.revision" /></th>
		<td>${revision.revision}</td>
	</tr>
	</table>
	<hr />
	<div align="right">
	  <html:submit><bean:message key="deleterev.jsp.submit" /></html:submit>
	</div>
</html:form>
	
</body>
</html>
