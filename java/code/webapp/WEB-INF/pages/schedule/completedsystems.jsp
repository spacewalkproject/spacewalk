<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

<h2><bean:message key="completedsystems.jsp.completedsystems"/></h2>

<form method="POST" name="rhn_list" action="/rhn/schedule/CompletedSystemsSubmit.do">

<rhn:list pageList="${requestScope.pageList}"
          noDataText="completedsystems.jsp.nogroups">

  <rhn:listdisplay>
    <rhn:column header="actions.jsp.system"
                url="/network/systems/details/history/event.pxt?sid=${current.id}&hid=${action.id}">
        ${current.name}
    </rhn:column>

    <rhn:column header="completedsystems.jsp.completed">
        ${current.displayDate}
    </rhn:column>

    <rhn:column header="actions.jsp.basechannel">
        ${current.channelLabels}
    </rhn:column>
  </rhn:listdisplay>

  <input type="hidden" name="aid" value="${action.id}" />
  <input type="hidden" name="formvars" value="aid" />

</rhn:list>
	
</form>
</body>
</html>
