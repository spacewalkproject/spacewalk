<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:html xhtml="true">
<head>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif"
               imgAlt="system.common.kickstartAlt">
  <bean:message key ="kickstart.advanced.jsp.create"/>
</rhn:toolbar>
<c:import url="/WEB-INF/pages/common/fragments/kickstart/advanced/details.jspf">
	<c:param name = "title_key" value="Kickstart Details"/>
	<c:param name = "summary_key" value="kickstart.advanced.jsp.para1"/>
	<c:param name = "action_key" value="message.Create"/>
	<c:param name = "url" value="/kickstart/AdvancedModeCreate.do"/>
</c:import>
</body>
</html:html>