<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"
	prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"
	prefix="html"%>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html>
<body>
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<div class="panel panel-default">
	<div class="panel-heading">
		<h4><bean:message key="channelsystems.jsp.header2" /></h4>
	</div>
	<div class="panel-body">
		<c:set var="beanarg" scope="request">
		<cfg:channel id="${channel.id}"
		               name="${channel.displayName}"
		               type="${channel.configChannelType.label}" />
		</c:set>
		<bean:message key="channelsystems.jsp.descr"
		    arg0="${beanarg}" />
		<html:form action="/configuration/channel/ChannelSystemsSubmit.do?ccid=${ccid}">
		    <rhn:csrf />
			<html:hidden property="submitted" value="true" />
			<rhn:list
			  pageList="${requestScope.pageList}"
			  noDataText="channelsystems.jsp.noSystemsFound">

			<rhn:listdisplay filterBy="system.common.systemName"
			 set="${requestScope.set}"
			 button="channelsystems.jsp.unsubscribe"
			 buttonAcl="user_role(config_admin)">
			    <rhn:require acl="user_role(config_admin)">
		          <rhn:set value="${current.id}"/>
		        </rhn:require>

				<rhn:column header="system.common.systemName"
					url="/rhn/systems/details/configuration/Overview.do?sid=${current.id}">
					<i class="fa fa-desktop"></i>
					${fn:escapeXml(current.name)}
		      	</rhn:column>

		        <rhn:column header="channelsystems.jsp.overridden"
				 url="/rhn/systems/details/configuration/ViewModifyLocalPaths.do?sid=${current.id}">
					<bean:message key="channelsystems.jsp.numfiles" arg0="${current.overriddenCount}" />
				</rhn:column>

				<rhn:column header="channelsystems.jsp.outranked"
					url="/rhn/systems/details/configuration/RankChannels.do?sid=${current.id}">
					<bean:message key="channelsystems.jsp.numfiles" arg0="${current.outrankedCount}" />
				</rhn:column>
			</rhn:listdisplay>
		</rhn:list>
		</html:form>
	</div>
</div>
</body>
</html>

