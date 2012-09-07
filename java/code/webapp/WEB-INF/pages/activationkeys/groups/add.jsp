<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<c:set var="msg_key" value="activation-keys.groups.add.jsp.noGroups" />
<c:set var="msg_arg0" value="/rhn/activationkeys/groups/List.do?tid=${param.tid}" />
<c:set var="summary_key" value="activation-key.groups.add.jsp.summary" />
<c:set var="summary_arg0" value="${rhn:localize('activation-key.groups.jsp.add')}"/>

<c:import url="/WEB-INF/pages/common/fragments/activationkeys/groups.jspf">
	<c:param name = "title_key" value="activation-key.groups.add.jsp.title"/>
	<c:param name = "summary_key" value="${summary_key}"/>
	<c:param name = "summary_arg0" value="${summary_arg0}"/>
	<c:param name = "action_key" value="activation-key.groups.jsp.add"/>
	<c:param name = "empty_message_key" value="${msg_key}"/>
	<c:param name = "empty_message_arg0" value="${msg_arg0}"/>
</c:import>
