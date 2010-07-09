<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:xhtml/>
<html>
<head>
    <meta name="name" value="copy2systems.jsp.header" />
</head>
<body>
<%@ include	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<h2><bean:message key="copy2systems.jsp.header2" /></h2>

<bean:message key="copy2systems.jsp.description"/>

<c:set var="pageList" value="${requestScope.pageList}" />
<rl:listset name="systemSet">
	<!-- Start of Systems list -->
	<rl:list dataset="pageList"
	         name="systems"
	         decorator="SelectableDecorator"
	         width="100%"
	         >
	    <rl:selectablecolumn value="${current.id}"
		selected="${current.selected}"
	    	styleclass="first-column"/>
	    <!--  System Name -->
		<rl:column bound="false"
			headerkey="system.common.systemName"
			sortable="true"
			sortattr="name">
			<a href="/rhn/systems/details/configuration/Overview.do?sid=${current.id}">
			  <img src="/img/rhn-listicon-system.gif"
			       alt="<bean:message key='system.common.systemAlt' />" />
			  ${current.name}
			</a>
		</rl:column>
	</rl:list>
	<hr />
	<div align="right">
		<input type="submit"
				name="dispatch"
				value="${rhn:localize('copy2systems.jsp.doCopy')}"
				/>	
	</div>
	<rhn:submitted/>
</rl:listset>
</body>
</html>
