<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:import url="/WEB-INF/pages/common/fragments/kickstart/deleteconfirm.jspf">
	<c:param name = "nav" value="/WEB-INF/nav/kickstart_raw_mode.xml"/>
	<c:param name = "post_url" value="/kickstart/KickstartDeleteAdvanced.do"/>
	<c:param name = "noComments" value="True"/>
</c:import>