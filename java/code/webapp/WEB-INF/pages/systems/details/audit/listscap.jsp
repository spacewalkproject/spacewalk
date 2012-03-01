<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:xhtml/>
<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="system.audit.listscap.jsp.overview"/></h2>

<c:choose>
	<c:when test="${not requestScope.scapEnabled}">
		<p><bean:message key="system.audit.listscap.jsp.missing"
			arg0="spacewalk-openscap"/></p>
		<br/>
	</c:when>
</c:choose>

<%@ include file="/WEB-INF/pages/common/fragments/audit/scap-list.jspf" %>

</body>
</html>
