<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-keyring.gif"
			imgAlt="activation-keys.common.alt"
			helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-systems-activation-keys"
			>
  <bean:message key ="activation-key.jsp.create"/>
</rhn:toolbar>
<c:import url="/WEB-INF/pages/common/fragments/activationkeys/details.jspf">
	<c:param name = "url" value="/activationkeys/Create.do"/>
	<c:param name = "submit" value="activation-key.jsp.create-key"/>
</c:import>

</body>
</html:html>
