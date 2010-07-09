<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<c:set var="msg"><bean:message key="activation-keys.groups.jsp.noGroups"
				 arg0="/rhn/activationkeys/groups/Add.do?tid=${param.tid}"
				 arg1 = "${rhn:localize('Join')}"/></c:set>

<c:set var="summary"><bean:message key="activation-key.groups.jsp.summary"
					arg0="${rhn:localize('activation-key.groups.jsp.remove')}"/></c:set>

<c:import url="/WEB-INF/pages/common/fragments/activationkeys/groups.jspf">
	<c:param name = "title_key" value="activation-key.groups.jsp.title"/>
	<c:param name = "summary" value="${summary}"/>
	<c:param name = "action_key" value="activation-key.groups.jsp.remove"/>
	<c:param name = "empty_message" value="${msg}"/>
</c:import>