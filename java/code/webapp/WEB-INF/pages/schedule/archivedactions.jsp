<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

  <rhn:toolbar base="h1" img="/img/rhn-icon-schedule_computer.gif"
  			   imgAlt="actions.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en/s2-sm-action-arch.jsp">
    <bean:message key="archivedactions.jsp.archived_actions"/>
  </rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="archivedactions.jsp.summary"/>
    </p>
  </div>
  
<form method="post" name="rhn_list" action="/rhn/schedule/ArchivedActionsSubmit.do">

<rhn:list pageList="${requestScope.pageList}"
          noDataText="archivedactions.jsp.nogroups">
          
  <rhn:listdisplay>
    <rhn:column header="actions.jsp.action"
                url="ActionDetails.do?aid=${current.id}">
        ${current.actionName}
    </rhn:column>
    <rhn:column header="actions.jsp.earliest">
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
	
</form>
</body>
</html>
