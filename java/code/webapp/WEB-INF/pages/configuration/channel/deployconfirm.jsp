<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://struts.apache.org/tags-html"	prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html>
<head>
</head>
<body>

<!--  Header and notes  -->
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<h2><bean:message key="deployconfirm.jsp.h2" /></h2>
<bean:message key="deployconfirm.jsp.note" />

<c:set var="channel_name_display"><cfg:channel id="${ccid}"
									name="${channel.name}"
									type="global"/></c:set>
<p><bean:message key="deploysystems.jsp.warning" arg0="${channel_name_display}"/></p>
<rl:listset name="lists">
    <rhn:csrf />
	<html:hidden property="submitted" value="true" />
	<div>
	<rl:list dataset="selectedFiles" name="fileList"
		styleclass="list" emptykey="deployconfirm.jsp.noFiles" width="100%"
		filter="com.redhat.rhn.frontend.action.configuration.ConfigFileFilter" >
		<rl:column headerkey="deploy.jsp.filepath-header" sortable="true" sortattr="path">
			<cfg:file id="${current.id}"  path="${current.path}" type="${current.type}" />
		</rl:column>

		<rl:column headerkey="deploy.jsp.actions-header" bound="false" sortable="false">
			[<a href='/rhn/configuration/file/FileDetails.do?cfid=${current.id}'><bean:message key="config.common.view"/></a>]
			|
			[<a href='/rhn/configuration/file/CompareRevision.do?cfid=${current.id}'><bean:message key="config.common.compare"/></a>]
		</rl:column>

		<rl:column headerkey="deploy.jsp.lastmodified-header" sortable="true" sortattr="modifiedDisplay">
			<c:out value="<a href='/rhn/configuration/file/FileDetails.do?cfid=${current.id}'>${current.modifiedDisplay}</a>" escapeXml="false" />
		</rl:column>

		<rl:column headerkey="deploy.jsp.current-header" sortable="false">
			<a href="/rhn/configuration/file/FileDetails.do?cfid=${current.id}&crid=${current.latestConfigRevisionId}">
			  <bean:message key="config.common.revision" arg0="${current.latestConfigRevision}"/>
			</a>
		</rl:column>
	</rl:list>
	</div>


	<h2><bean:message key="deployconfirm.jsp.systems-header2" /></h2>
	<!--  Systems-list -->
	<div>
	<rl:list dataset="selectedSystems" name="systemList"
		styleclass="list" emptykey="deployconfirm.jsp.noSystems" width="100%"
		filter="com.redhat.rhn.frontend.action.configuration.ConfigSystemFilter" >
		<rl:column headerkey="system.common.systemName" sortable="true" sortattr="name">
			<rhn:icon type="header-system-physical" title="system.common.systemAlt" />
			<a href="/rhn/systems/details/configuration/Overview.do?system_detail_navi_node=selected_configfiles&sid=${current.id}">
			 ${fn:escapeXml(current.name)}
			</a>
		</rl:column>
	</rl:list>
	</div>

	<c:if test="${not empty requestScope.selectedSystems && not empty requestScope.selectedFiles}">
	<!--  Date picker  -->
	<p><bean:message key="deployconfirm.jsp.widgetsummary" /></p>
    <jsp:include page="/WEB-INF/pages/common/fragments/datepicker-with-label.jsp">
        <jsp:param name="widget" value="date" />
        <jsp:param name="label_text" value="deployconfirm.jsp.usedate" />
    </jsp:include>
	<!--  DoIt Button -->
	<div class="text-right">
		<html:submit styleClass="btn btn-default" property="dispatch">
			<bean:message key="deployconfirm.jsp.confirmbutton" />
		</html:submit>
	</div>
	</c:if>
</rl:listset>
</body>
</html>
