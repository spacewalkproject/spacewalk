<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<c:import url="/WEB-INF/pages/common/fragments/kickstart/ipranges.jspf">
	<c:param name = "range_delete_url" value="/rhn/kickstart/KickstartIpRangeDelete.do"/>
	<c:param name = "range_edit_url" value="/kickstart/KickstartIpRangeEdit.do"/>
</c:import>
</body>
</html:html>

