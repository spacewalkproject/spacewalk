<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<c:import url="/WEB-INF/pages/common/fragments/activationkeys/groups.jspf">
        <c:param name = "title_key" value="activation-key.groups.add.jsp.title"/>
        <c:param name = "summary_key" value="activation-key.groups.add.jsp.summary"/>
        <c:param name = "summary_arg0" value="activation-key.groups.jsp.add"/>
        <c:param name = "action_key" value="activation-key.groups.jsp.add"/>
        <c:param name = "empty_message_key" value="activation-keys.groups.add.jsp.noGroups"/>
        <c:param name = "empty_message_arg0" value="/rhn/activationkeys/groups/List.do?tid=${param.tid}"/>
</c:import>
