<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"	prefix="html"%>


<html>
<body>
<%@ include	file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf"%>

<h2><bean:message key="deployconfirm.jsp.header2" /></h2>

<c:if test="{requestScope.pageList.size > 0}">
<bean:message key="deployconfirm.jspf.note" arg0="${revision.revision}"
	arg1="/rhn/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${revision.id}"
	arg2="${channel.displayName}"
	arg3="/rhn/configuration/ChannelOverview.do?ccid=${ccid}" />
</c:if>

<html:form
	action="/configuration/file/GlobalRevisionDeployConfirmSubmit.do?cfid=${cfid}&amp;crid=${crid}">
    <rhn:csrf />
	<html:hidden property="submitted" value="true" />
	<div>
	<rhn:list pageList="${requestScope.pageList}"
		noDataText="deployconfirm.jsp.noSystems">
		<rhn:listdisplay filterBy="globaldeploy.jsp.systemName">
			<rhn:column header="globaldeploy.jsp.systemName-header"
				url="/rhn/systems/details/Overview.do?sid=${current.id}">
        	${current.name}
    		</rhn:column>
		</rhn:listdisplay>
	</rhn:list>

	<c:if test="${not empty requestScope.pageList}">
	<div>
	<bean:message key="deploy.jsp.widgetsummary" /></p>
    <jsp:include page="/WEB-INF/pages/common/fragments/schedule-options.jspf"/>
	</div>
	<hr />
	<div class="text-right">
		<html:submit styleClass="btn btn-default" property="dispatch">
			<bean:message key="deployconfirm.jsp.deploybutton" />
		</html:submit>
	</div>
	</c:if>
</html:form>
</body>
</html>
