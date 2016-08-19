<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
        <bean:message key="virtualguests_confirm.jsp.header" />
</h2>
<div class="page-summary">
        <p>
      <c:choose>
        <c:when test="${param.actionName == 'delete'}">
          <bean:message key="virtualguests_confirm.jsp.summary.delete" />
        </c:when>
        <c:otherwise>
          <bean:message key="virtualguests_confirm.jsp.summary" />
        </c:otherwise>
      </c:choose>
        </p>
</div>

<form method="POST" name="rhn-list" action="/rhn/systems/details/virtualization/VirtualGuestsConfirmSubmit.do">
  <rhn:csrf />
  <rhn:list pageList="${requestScope.pageList}" noDataText="virtualguests_confirm.jsp.nosystems"
          legend="system">

  <rhn:listdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}"
                   filterBy="virtualguests_confirm.jsp.guestname" domainClass="systems">

    <rhn:column header="virtualguests_confirm.jsp.guestname">
      ${current.name}
    </rhn:column>

    <rhn:column header="virtualguests_confirm.jsp.hostname">
      <c:choose>
        <c:when test="${current.virtualSystemId == null}">
          <bean:message key="virtualguests_confirm.jsp.unregistered" />
        </c:when>
        <c:otherwise>
          <a href="/rhn/systems/details/Overview.do?sid=${current.virtualSystemId}">
            ${current.serverName}
          </a>
        </c:otherwise>
      </c:choose>
    </rhn:column>

    <rhn:column header="virtualguests_confirm.jsp.state">
        ${current.stateName}
    </rhn:column>

    <rhn:column header="virtualguests_confirm.jsp.action">
      <c:choose>
        <c:when test="${current.doAction}">
          ${current.actionName}
        </c:when>
        <c:otherwise>
          <bean:message key="virtualguests_confirm.jsp.noaction"/> - ${current.noActionReason}
        </c:otherwise>
      </c:choose>
    </rhn:column>

  </rhn:listdisplay>

  </rhn:list>

  <div class="text-right">

    <hr />

    <html:submit styleClass="btn btn-success" property="dispatch">
      <bean:message key="virtualguests_confirm.jsp.confirm"/>
    </html:submit>

  </div>

  <rhn:hidden name="actionName" value="${param.actionName}" />
  <rhn:hidden name="sid" value="${param.sid}" />
  <rhn:hidden name="guestSettingValue" value="${param.guestSettingValue}" />

</form>

</div>

</body>
</html>

