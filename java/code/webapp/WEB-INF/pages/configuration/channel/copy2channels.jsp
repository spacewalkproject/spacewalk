<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
<head>
    <meta name="name" value="copy2channels.jsp.header" />
</head>
<body>
<%@ include	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<c:import url="/WEB-INF/pages/common/fragments/configuration/copy2channels.jspf">
	<c:param name = "header" value="copy2channels.jsp.header2"/>
	<c:param name = "description" value="copy2channels.jsp.description"/>
</c:import>
</body>
</html>
