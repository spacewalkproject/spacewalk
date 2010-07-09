<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html"	prefix="html"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml />
<html>
<head>
<meta name="page-decorator" content="none" />
</head>
<body>

<!--  Header and notes  -->
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<h2><bean:message key="deployconfirm.jsp.h2" /></h2>
<bean:message key="deployconfirm.jsp.note" />
<p />
<c:set var="channel_name_display"><cfg:channel id="${ccid}"
									name="${channel.name}"
									type="global"/></c:set>
<p><bean:message key="deploysystems.jsp.warning" arg0="${channel_name_display}"/></p>
<rl:listset name="lists">
	<html:hidden property="submitted" value="true" />
	<div>
	<rl:list dataset="selectedFiles" name="fileList"
		styleclass="list" emptykey="deployconfirm.jsp.noFiles" width="100%"
		filter="com.redhat.rhn.frontend.action.configuration.ConfigFileFilter" >
		<rl:column headerkey="deploy.jsp.filepath-header" sortable="true" sortattr="path" styleclass="first-column">
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

		<rl:column headerkey="deploy.jsp.current-header" sortable="false" styleclass="last-column">
			<a href="/rhn/configuration/file/FileDetails.do?cfid=${current.id}&crid=${current.latestConfigRevisionId}">
			  <bean:message key="config.common.revision" arg0="${current.latestConfigRevision}"/>
			</a>
		</rl:column>
	</rl:list>
	</div>
	<p />
	<p />
	<h2><bean:message key="deployconfirm.jsp.systems-header2" /></h2>
	<!--  Systems-list -->
	<div>
	<rl:list dataset="selectedSystems" name="systemList"
		styleclass="list" emptykey="deployconfirm.jsp.noSystems" width="100%"
		filter="com.redhat.rhn.frontend.action.configuration.ConfigSystemFilter" >
		<rl:column headerkey="system.common.systemName" sortable="true" sortattr="name" styleclass="first-column">
			<img alt='<bean:message key="system.common.systemAlt"/>' src="/img/rhn-listicon-system.gif" />
			<a href="/rhn/systems/details/configuration/Overview.do?system_detail_navi_node=selected_configfiles&sid=${current.id}">
			 ${fn:escapeXml(current.name)}
			</a>
		</rl:column>
	</rl:list>
	</div>
	
	<c:if test="${not empty requestScope.selectedSystems && not empty requestScope.selectedFiles}">
	<!--  Date picker  -->
	<p><bean:message key="deployconfirm.jsp.widgetsummary" /></p>
	<table class="schedule-action-interface" align="center">
	    <tr>
	        <td><input type="radio" name="use_date" checked="checked" value="false" /></td>
	        <th><bean:message key="deployconfirm.jsp.now"/></th>
	    </tr>
	    <tr>
	        <td><input type="radio" name="use_date" value="true" /></td>
	        <th><bean:message key="deployconfirm.jsp.usedate"/></th>
	    </tr>
	    <tr>
	        <th><img src="/img/rhn-icon-schedule.gif" alt="<bean:message key="syncprofile.jsp.selection"/>"
	                                                  title="<bean:message key="syncprofile.jsp.selection"/>"/>
	        </th>
	        <td>
	          <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
	            <jsp:param name="widget" value="date"/>
	          </jsp:include>
	        </td>
	    </tr>
	</table>
	<!--  DoIt Button -->
	<div align="right">
		<html:submit property="dispatch">
			<bean:message key="deployconfirm.jsp.confirmbutton" />
		</html:submit>
	</div>
	</c:if>
</rl:listset>
</body>
</html>
