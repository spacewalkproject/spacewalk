<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

<h2><bean:message key="completedsystems.jsp.completedsystems"/></h2>

<form method="POST" role="form" name="rhn_list" action="/rhn/schedule/CompletedSystemsSubmit.do">
<rhn:csrf />

<rhn:list pageList="${requestScope.pageList}"
          noDataText="completedsystems.jsp.nogroups">

  <rhn:listdisplay>
    <rhn:column header="actions.jsp.system"
                url="/rhn/systems/details/history/Event.do?sid=${current.id}&aid=${action.id}">
        <c:out value="${current.name}" escapeXml="true" />
    </rhn:column>

    <rhn:column header="completedsystems.jsp.completed">
        ${current.displayDate}
    </rhn:column>

    <rhn:column header="actions.jsp.basechannel">
        ${current.channelLabels}
    </rhn:column>
  </rhn:listdisplay>

  <rhn:hidden name="aid" value="${action.id}" />
  <rhn:hidden name="formvars" value="aid" />

</rhn:list>

</form>
</body>
</html>
