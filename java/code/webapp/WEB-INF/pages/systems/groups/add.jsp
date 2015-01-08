<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<c:import url="/WEB-INF/pages/common/fragments/systems/groups.jspf">
        <c:param name = "title_key" value="systems.groups.add.jsp.title"/>
        <c:param name = "summary_key" value="systems.groups.add.jsp.summary"/>
        <c:param name = "summary_arg0" value="systems.groups.jsp.add"/>
        <c:param name = "action_key" value="systems.groups.jsp.add"/>
        <c:param name = "empty_message_key" value="systems.groups.add.jsp.noGroups"/>
        <c:param name = "empty_message_arg0" value="/rhn/systems/details/groups/ListRemove.do?sid=${param.sid}"/>
</c:import>
