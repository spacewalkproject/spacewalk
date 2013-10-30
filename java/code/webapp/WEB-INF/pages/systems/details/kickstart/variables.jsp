<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>



<html>
<head>
    <meta name="name" value="System Details" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<c:import url="/WEB-INF/pages/common/fragments/kickstart/cobbler-variables.jspf">
	<c:param name = "post_url" value="/systems/details/kickstart/Variables.do"/>
	<c:param name = "name" value="sid"/>
	<c:param name = "value" value="${param.sid}"/>
	<c:param name = "show_netboot" value="True"/>
</c:import>

</body>
</html>
