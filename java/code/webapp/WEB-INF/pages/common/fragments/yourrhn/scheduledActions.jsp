<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
  <c:when test="${requestScope.showPendingActions == 'true'}">
  <form method="post" name="rhn_list" action="/YourRhn.do">
    <rhn:list pageList="${requestScope.scheduledActionList}"
              noDataText="${requestScope.scheduledActionEmpty}"
              formatMessage="false">
  <rhn:listdisplay title="yourrhn.jsp.scheduledactions"
                   set="${requestScope.set}"
                   paging="false"
                   description="yourrhn.jsp.actions.description"
                   type="list">

    <rhn:column header="schedulesync.jsp.action">
        <c:choose>
            <c:when test="${current.actionStatusId == 0 || current.actionStatusId == 1}">
                <rhn:icon type="action-pending" title="<bean:message key='yourrhn.jsp.actions.pending' />" />
            </c:when>
            <c:when test="${current.actionStatusId == 2}">
                <rhn:icon type="action-ok" title="<bean:message key='yourrhn.jsp.actions.completed' />" />
            </c:when>
            <c:when test="${current.actionStatusId == 3}">
                <rhn:icon type="action-failed" title="<bean:message key='yourrhn.jsp.actions.failed' />" />
            </c:when>
            <c:otherwise>
                <rhn:icon type="system-unknown" title="<bean:message key='yourrhn.jsp.actions.unknown' />" />
            </c:otherwise>
        </c:choose>
      <a href="/rhn/schedule/ActionDetails.do?aid=${current.id}"><c:out value="${current.actionName}" /></a>
    </rhn:column>

        <rhn:column header="yourrhn.jsp.user"
                    style="text-align: center;">
        <c:choose>
            <c:when test="${current.userName != ''}">
                <rhn:icon type="header-user" title="<bean:message key='yourrhn.jsp.user.alt'/>" />
                ${current.userName}
            </c:when>
            <c:otherwise>
                <bean:message key="none.message"/>
            </c:otherwise>
        </c:choose>
    </rhn:column>



    <rhn:column header="yourrhn.jsp.age"
                style="text-align: center;">
           ${current.ageString}
    </rhn:column>
  </rhn:listdisplay>

  <span class="full-width-note-right">
      <a href="/rhn/schedule/PendingActions.do">
          <bean:message key="yourrhn.jsp.allactions" />
      </a>
  </span>
</rhn:list>
</form>
</c:when>
</c:choose>
