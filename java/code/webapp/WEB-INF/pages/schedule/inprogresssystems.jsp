<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<body>
  <%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

  <h2><bean:message key="inprogresssystems.jsp.inprogresssystems"/></h2>

  <form method="POST" role="form" name="rhn_list" action="/rhn/schedule/InProgressSystemsSubmit.do">
    <rhn:csrf />


    <rhn:list pageList="${requestScope.pageList}"
              noDataText="inprogresssystems.jsp.nogroups">

      <rhn:listdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}"
                       button="actions.jsp.unscheduleaction"
                       buttonsAttr="canEdit:true">
        <rhn:set value="${current.id}" />
        <rhn:column header="actions.jsp.system"
                    url="/rhn/systems/details/history/Event.do?sid=${current.id}&amp;aid=${action.id}">
            <c:out value="${current.serverName}" escapeXml="true" />
        </rhn:column>

        <rhn:column header="actiondetails.jsp.earliestexecution">
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
