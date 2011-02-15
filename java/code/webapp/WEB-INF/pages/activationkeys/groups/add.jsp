<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<c:set var="msg"><bean:message key="activation-keys.groups.add.jsp.noGroups"
					arg0="/rhn/activationkeys/groups/List.do?tid=${param.tid}"
					/></c:set>
<c:set var="summary"><bean:message key="activation-key.groups.add.jsp.summary"
					arg0="${rhn:localize('activation-key.groups.jsp.add')}"/></c:set>

<c:import url="/WEB-INF/pages/common/fragments/activationkeys/groups.jspf">
	<c:param name = "title_key" value="activation-key.groups.add.jsp.title"/>
	<c:param name = "summary" value="${summary}"/>
	<c:param name = "action_key" value="activation-key.groups.jsp.add"/>
	<c:param name = "empty_message" value="${msg}"/>
</c:import>
