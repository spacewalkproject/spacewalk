<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
 <rhn:require acl="user_role(org_admin) or user_role(system_group_admin)">
<c:set var="summary_key" value="systemgroup.systems.summary" />
<c:set var="summary_arg0" value="${rhn:localize('systemgroup.systems.remove')}" />
 </rhn:require>
<rhn:require acl="not user_role(org_admin);not user_role(system_group_admin)">
 <c:set var="summary_key" value="systemgroup.systems.summary.nonadmin"/>
 </rhn:require>

<c:import url="/WEB-INF/pages/common/fragments/groups/systems.jspf">
	<c:param name = "title_key" value="Systems"/>
	<c:param name = "summary_key" value="${summary_key}"/>
	<c:param name = "summary_arg0" value="${summary_arg0}"/>
	<c:param name = "action_key" value="systemgroup.systems.remove"/>
</c:import>

