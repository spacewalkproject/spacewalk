<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>

<c:import url="/WEB-INF/pages/common/fragments/activationkeys/details.jspf">
	<c:param name = "url" value="/activationkeys/Edit.do?tid=${param.tid}"/>
	<c:param name = "tid" value="${param.tid}"/>
	<c:param name = "submit" value="activation-key.jsp.edit-key"/>
</c:import>

</body>
</html:html>
