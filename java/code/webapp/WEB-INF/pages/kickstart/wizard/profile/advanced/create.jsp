<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<html:html xhtml="true">
<head>
<meta http-equiv="Pragma" content="no-cache" />
<script language="javascript" type="text/javascript">
function clickNewestRHTree(obj) {
   if (obj.checked == true) {
       document.getElementById("updateAll").checked = false;
   }
}

function clickNewestTree(obj) {
   if (obj.checked == true) {
       document.getElementById("updateRedHat").checked = false;
   }
}
</script>
</head>
<body>
<rhn:toolbar base="h1" icon="icon-rocket"
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
