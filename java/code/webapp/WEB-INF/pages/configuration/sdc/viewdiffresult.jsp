<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<c:set var="revisionBean" value="${requestScope.revisionBean}"/>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
<rhn:toolbar base="h2" icon="header-configuration">
<bean:message key="sdc.config.header.diff_result"/>
</rhn:toolbar>
<p>

<c:set var="path"
		value="${revisionBean.configRevision.configFile.configFileName.path}"/>

<c:set var="revValue">
(<strong><a href="${cfg:fileRevisionUrl(revisionBean.configRevision.configFile.id, revisionBean.configRevision.id)}"><bean:message key="sdc.config.diff_result.rev"
					arg0="${revisionBean.configRevision.revision}"/></strong></a>)
</c:set>


<c:set var="fileValue"><strong><cfg:file
		 path = "${path}"
		 id = "${revisionBean.configRevision.configFile.id}"
		 type = "${revisionBean.configRevision.configFileType.label}"
				/></strong></c:set>
<c:set var="compareFileValue"><strong><cfg:file
		 path = "${path}"
		 type = "${revisionBean.configRevision.configFileType.label}"
		 nolink="true"
				/></strong></c:set>
<c:set var="channel"
		value="${revisionBean.configRevision.configFile.configChannel}"/>

<c:set var="channelValue"><strong><cfg:channel
		 name = "${channel.name}"
		 id = "${channel.id}"
         type = "${channel.configChannelType.label}"
		/></strong></c:set>

<c:set var="systemValue"><strong><a href="/rhn/systems/details/configuration/Overview.do?sid=${current.id}"><rhn:icon type="header-system" /> ${fn:escapeXml(current.name)} </a></strong></c:set>


<table class="details">
	<tr>
		<th><bean:message key="sdc.config.diff_result.original_file"/>:</th>
			<td><bean:message key="sdc.config.diff_result.original_file_value"
									arg0="${fileValue}"
									arg1="${revValue}"
									arg2="${channelValue}"
									/>
			</td>
	</tr>
	<tr>
		<th><bean:message key="sdc.config.diff_result.compared_file"/>:</th>
			<td><bean:message key="sdc.config.diff_result.compared_file_value"
									arg0="${compareFileValue}"
									arg1="${systemValue}"
									/>
			</td>
	</tr>
	<tr>
		<th><bean:message key="sdc.config.diff_result.comparison_time"/>:</th>
			<td> <fmt:formatDate value="${revisionBean.modified}"
					type="both" dateStyle="short" timeStyle="long"/></td>
	</tr>
	<tr>
		<th><bean:message key="sdc.config.diff_result.diff"/>:</th>
			<td>
			<pre style="overflow: scroll; width: 100%; height: 400px;"><c:out value="${revisionBean.configRevisionActionResult.resultContents}"/></pre>
			</td>
	</tr>
</table>
</p>
</body>
