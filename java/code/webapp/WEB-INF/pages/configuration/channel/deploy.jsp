<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://struts.apache.org/tags-html"	prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml />

<html>
<body>
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<h2><bean:message key="deploy.jsp.h2" /></h2>
<bean:message key="deploy.jsp.description"/>

<html:form action="/configuration/channel/ChooseFilesSubmit.do?ccid=${ccid}">
    <rhn:csrf />
	<rhn:submitted/>
	<rhn:list pageList="${requestScope.pageList}" noDataText="channelfiles.jsp.noFiles">
		<rhn:listdisplay filterBy="deploy.jsp.filepath-header" set="${requestScope.set}">
      		<rhn:set value="${current.id}"/>
      		
			<rhn:column header="deploy.jsp.filepath-header">
        	  <cfg:file id="${current.id}"  path="${current.path}" type="${current.type}" />
    		</rhn:column>

			<rhn:column header="deploy.jsp.actions-header">
			[<a href="/rhn/configuration/file/FileDetails.do?cfid=${current.id}"><bean:message key="config.common.view" /></a>]
			|
			[<a href="/rhn/configuration/file/CompareRevision.do?cfid=${current.id}"><bean:message key="config.common.compare" /></a>]
			</rhn:column>
			
			<rhn:column header="deploy.jsp.lastmodified-header">
			  <a href="/rhn/configuration/file/FileDetails.do?cfid=${current.id}">${current.modifiedDisplay}</a>
			</rhn:column>
			
			<rhn:column header="deploy.jsp.current-header">
			  <a href="/rhn/configuration/file/FileDetails.do?cfid=${current.id}">
			    <bean:message key="config.common.revision" arg0="${current.latestConfigRevision}"/>
			  </a>
			</rhn:column>
		</rhn:listdisplay>
	</rhn:list>
<c:if test="${not empty requestScope.pageList}">
<hr />
	<div class="text-right">
		<html:submit property="dispatch"><bean:message key="deploy.jsp.deployallbutton" /></html:submit>
		<html:submit property="dispatch"><bean:message key="deploy.jsp.deployselectedbutton" /></html:submit>
	</div>
</c:if>
</html:form>
</body>
</html>
