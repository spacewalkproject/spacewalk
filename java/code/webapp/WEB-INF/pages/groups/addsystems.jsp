<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<c:set var="summary"><bean:message key="systemgroup.target-systems.summary"/></c:set>

<c:import url="/WEB-INF/pages/common/fragments/groups/systems.jspf">
	<c:param name = "title_key" value="Target Systems"/>
	<c:param name = "summary" value="${summary}"/>
	<c:param name = "action_key" value="systemgroup.target-systems.add"/>
</c:import>
