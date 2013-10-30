<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"	prefix="html"%>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>


<html>
<body>
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<div class="panel panel-default">
	<div class="panel-heading">
		<h4><bean:message key="targetsystems.jsp.header2" /></h4>
	</div>
	<div class="panel-body">
		<c:set var="beanarg" scope="request">
		<cfg:channel id="${channel.id}" name="${channel.displayName}"
		               type="${channel.configChannelType.label}" />
		</c:set>
		<bean:message key="targetsystems.jsp.descr"
		    arg0="${beanarg}" />

		<html:form
			action="/configuration/channel/TargetSystemsSubmit.do?ccid=${ccid}">
		    <rhn:csrf />
			<html:hidden property="submitted" value="true" />
			<rhn:list
			  pageList="${requestScope.pageList}"
			  noDataText="targetsystems.jsp.noSystemsFound">

			<rhn:listdisplay filterBy="system.common.systemName"
			 set="${requestScope.set}"
			 button="targetsystems.jsp.subscribe">
			 	<rhn:set value="${current.id}"/>
				<rhn:column header="system.common.systemName"
					url="/rhn/systems/details/Overview.do?sid=${current.id}">
					<i class="fa fa-desktop"></i>
					<c:out value="${current.name}" escapeXml="true" />
		      	</rhn:column>
			</rhn:listdisplay>
		</rhn:list>
		</html:form>
	</div>
</div>

</body>
</html>

