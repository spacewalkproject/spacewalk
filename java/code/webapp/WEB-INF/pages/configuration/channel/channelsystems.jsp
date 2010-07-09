<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean"
	prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html"
	prefix="html"%>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml/>
<html>
<body>
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<h2><bean:message key="channelsystems.jsp.header2" /></h2>
<c:set var="beanarg" scope="request">
  <cfg:channel id="${channel.id}"
               name="${channel.displayName}"
               type="${channel.configChannelType.label}" />
</c:set>
<bean:message key="channelsystems.jsp.descr"
    arg0="${beanarg}" />

<div>
<html:form action="/configuration/channel/ChannelSystemsSubmit.do?ccid=${ccid}">
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
			<img src="/img/rhn-listicon-system.gif"
			       alt="<bean:message key='system.common.systemAlt' />" />
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
</body>
</html>

