<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
<head>
<meta http-equiv="Pragma" content="no-cache" />
</head>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/advanced/header.jspf"%>
<c:import url="/WEB-INF/pages/common/fragments/kickstart/advanced/details.jspf">
	<c:param name = "title_key" value="Kickstart Details"/>
	<c:param name = "summary_key" value="kickstartdetails.jsp.summary1"/>
	<c:param name = "action_key" value="message.Update"/>
	<c:param name = "url" value="/kickstart/AdvancedModeEdit.do"/>
	<c:param name = "ksurl" value="${requestScope.ksurl}"/>	
</c:import>
</body>
</html:html>