<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html"	prefix="html"%>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>

<html:xhtml/>
<html>
<body>
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<h2><bean:message key="targetsystems.jsp.header2" /></h2>

<c:set var="beanarg" scope="request">
  <cfg:channel id="${channel.id}" name="${channel.displayName}"
               type="${channel.configChannelType.label}" />
</c:set>
<bean:message key="targetsystems.jsp.descr"
    arg0="${beanarg}" />

<div>
<html:form
	action="/configuration/channel/TargetSystemsSubmit.do?ccid=${ccid}">
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
			<img alt="" src="/img/rhn-listicon-system.gif" /> ${current.name}
      	</rhn:column>
	</rhn:listdisplay>
</rhn:list>
</html:form>
</div>
</body>
</html>

