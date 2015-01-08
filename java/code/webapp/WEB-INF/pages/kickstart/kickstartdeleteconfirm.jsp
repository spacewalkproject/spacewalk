<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:import url="/WEB-INF/pages/common/fragments/kickstart/deleteconfirm.jspf">
        <c:param name = "nav" value="/WEB-INF/nav/kickstart_details.xml"/>
        <c:param name = "post_url" value="/kickstart/KickstartDelete.do"/>
</c:import>
