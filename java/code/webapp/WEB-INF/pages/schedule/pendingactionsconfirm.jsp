<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

  <html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
  </html:messages>

  <rhn:toolbar base="h1" img="/img/rhn-icon-schedule_computer.gif"
  			   imgAlt="actions.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en/s2-sm-action-pend.jsp">
    <bean:message key="pendingactions.jsp.confirm_cancel_actions"/>
  </rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="pendingactions.jsp.confirm_cancel_actions_summary"/>
    </p>
  </div>
  
<form method="post" name="rhn_list" action="/rhn/schedule/PendingActionsDeleteConfirmSubmit.do">

<rhn:list pageList="${requestScope.pageList}"
          noDataText="pendingactions.jsp.nogroups">

  <rhn:listdisplay set="${requestScope.set}" button="actions.jsp.confirmcancelactions">
    <rhn:column header="actions.jsp.action"
                url="ActionDetails.do?aid=${current.id}">
        ${current.actionName}
    </rhn:column>
    <rhn:column header="actions.jsp.earliest" nowrap="true">
        ${current.earliest}
    </rhn:column>
    <rhn:column header="actions.jsp.succeeded"
                style="text-align: center;"
                url="CompletedSystems.do?aid=${current.id}"
                renderUrl="${current.completed != 0}">
        ${current.completed}
    </rhn:column>
    <rhn:column header="actions.jsp.failed"
                style="text-align: center;"
                url="FailedSystems.do?aid=${current.id}"
                renderUrl="${current.failed != 0}">
        ${current.failed}
    </rhn:column>
    <rhn:column header="actions.jsp.inprogress"
                style="text-align: center;"
                url="InProgressSystems.do?aid=${current.id}"
                renderUrl="${current.inProgress != 0}">
        ${current.inProgress}
    </rhn:column>
    <rhn:column header="actions.jsp.total" style="text-align: center;">
        ${current.tally}
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>
  

	
</body>
</html>

