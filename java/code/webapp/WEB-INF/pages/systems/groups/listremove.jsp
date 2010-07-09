<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>


<rhn:require acl="user_role(org_admin) or user_role(system_group_admin)">
 <c:set var="msg"><bean:message key="systems.groups.jsp.noGroups"
				 arg0="/rhn/systems/details/groups/Add.do?sid=${param.sid}"
				 arg1 = "${rhn:localize('Join')}"/></c:set>

<c:set var="summary"><bean:message key="systems.groups.jsp.summary"
					arg0="${rhn:localize('systems.groups.jsp.remove')}"/></c:set>
</rhn:require>

<rhn:require acl="not user_role(org_admin);not user_role(system_group_admin)">
<c:set var="msg"><bean:message key="systems.groups.jsp.noGroups.nonadmin"/></c:set>

<c:set var="summary"><bean:message key="systems.groups.jsp.summary.nonadmin"/></c:set>
</rhn:require>




<c:import url="/WEB-INF/pages/common/fragments/systems/groups.jspf">
	<c:param name = "title_key" value="systems.groups.jsp.title"/>
	<c:param name = "summary" value="${summary}"/>
	<c:param name = "action_key" value="systems.groups.jsp.remove"/>
	<c:param name = "empty_message" value="${msg}"/>
</c:import>