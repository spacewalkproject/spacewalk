<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean"
	prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html"
	prefix="html"%>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>

<html:xhtml/>
<html>
<body>
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<h2><bean:message key="channelfiles.jsp.header2" /></h2>

<bean:message key="channelfiles.jsp.description"/>
<p />
<div>
<html:form action="/configuration/ChannelFilesSubmit.do?ccid=${ccid}">
	<rhn:submitted/>
	<rhn:list
	  pageList="${requestScope.pageList}"
	  noDataText="channelfiles.jsp.noFiles">

	<rhn:listdisplay filterBy="channelfiles.jsp.path"
	 set="${requestScope.set}">
	 	<rhn:set value="${current.id}"/>
		<rhn:column header="channelfiles.jsp.path">
			<cfg:file id="${current.id}" path="${current.path}"
			          type="${current.type}" />
      	</rhn:column>

		<rhn:column header="channelfiles.jsp.actions">
			[<a href="/rhn/configuration/file/FileDetails.do?cfid=${current.id}">
				<bean:message key="config.common.view" /></a>] |
   			[<a href="/rhn/configuration/file/CompareRevision.do?cfid=${current.id}">
   				<bean:message key="config.common.compare" /></a>]
		</rhn:column>

		<rhn:column header="channelfiles.jsp.lastmod"
			url="/rhn/configuration/file/FileDetails.do?cfid=${current.id}">
			${current.modifiedDisplay}
		</rhn:column>

		<rhn:column header="channelfiles.jsp.currversion"
			url="/rhn/configuration/file/FileDetails.do?cfid=${current.id}">
			<bean:message key="channelfiles.jsp.revision" arg0="${current.latestConfigRevision}"/>
		</rhn:column>
	</rhn:listdisplay>
    </rhn:list>
<c:if test="${not empty requestScope.pageList}">
<hr />
  <div align="right">
    <rhn:require acl="config_channel_editable(channel.id)"
                 mixins="com.redhat.rhn.common.security.acl.ConfigAclHandler">
      <html:submit property="dispatch"><bean:message key="channelfiles.jsp.removeselected" /></html:submit>
    </rhn:require>
    <html:submit property="dispatch"><bean:message key="channelfiles.jsp.copy2systems" /></html:submit>
	<rhn:require acl="user_role(config_admin)">
      <html:submit property="dispatch"><bean:message key="channelfiles.jsp.copy2channels" /></html:submit>
    </rhn:require>
  </div>
</c:if>
</html:form>
</div>
</body>
</html>

