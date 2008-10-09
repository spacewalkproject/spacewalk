<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:html xhtml="true">
<head>
<meta http-equiv="Pragma" content="no-cache" />
</head>

<body>
<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>
<c:import url="/WEB-INF/pages/common/fragments/kickstart/advanced/details.jspf">
	<c:param name = "title_key" value="kickstart.jsp.upload.title"/>
	<c:param name = "summary_key" value="kickstart.jsp.upload.para1"/>
	<c:param name = "action_key" value="message.Update"/>
	<c:param name = "url" value="/kickstart/AdvancedModeCreate.do"/>
</c:import>
</body>
</html:html>