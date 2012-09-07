<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<c:set var="msg"><bean:message key="systems.groups.add.jsp.noGroups"
					arg0="/rhn/systems/details/groups/ListRemove.do?sid=${param.sid}"
					/></c:set>
<c:set var="summary_key" value="systems.groups.add.jsp.summary" />
<c:set var="summary_arg0" value="${rhn:localize('systems.groups.jsp.add')}" />

<c:import url="/WEB-INF/pages/common/fragments/systems/groups.jspf">
	<c:param name = "title_key" value="systems.groups.add.jsp.title"/>
	<c:param name = "summary_key" value="${summary_key}"/>
	<c:param name = "summary_arg0" value="${summary_arg0}"/>
	<c:param name = "action_key" value="systems.groups.jsp.add"/>
	<c:param name = "empty_message" value="${msg}"/>
</c:import>
