<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
 <rhn:require acl="user_role(org_admin) or user_role(system_group_admin)">
<c:set var="summary"><bean:message key="systemgroup.systems.summary"
					arg0="${rhn:localize('systemgroup.systems.remove')}"/></c:set>
 </rhn:require>
<rhn:require acl="not user_role(org_admin);not user_role(system_group_admin)">
 <c:set var="summary"><bean:message key="systemgroup.systems.summary.nonadmin"/></c:set>
 </rhn:require>

<c:import url="/WEB-INF/pages/common/fragments/groups/systems.jspf">
	<c:param name = "title_key" value="Systems"/>
	<c:param name = "summary" value="${summary}"/>
	<c:param name = "action_key" value="systemgroup.systems.remove"/>
</c:import>

