<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/groups/header.jspf" %>

  <rhn:require acl="not user_role(org_admin);not user_role(system_group_admin)">
    <c:set var="notSelectable" value="True" />
  </rhn:require>

  <h2>
    <rhn:icon type="event-type-errata" />
    <bean:message key="systemgroup.errata-systems-affected.title" arg0="${erratum.advisoryName}" arg1="${erratum.synopsis}" />
  </h2>
  <p>
    <div class="page-summary">
    <bean:message key="systemgroup.errata-systems-affected.summary" arg0="${systemgroup.name}" />
    </div>
  </p>
  <rl:listset name="systemListSet" legend="system">
    <rhn:csrf />
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>

    <c:if test="${not empty requestScope.pageList}">
      <rhn:require acl="user_role(org_admin) or user_role(system_group_admin)">
        <rhn:submitted />
        <hr />
        <div class="text-right">
          <html:submit property="dispatch">
            <bean:message key="affectedsystems.jsp.apply" />
          </html:submit>
       </div>
      </rhn:require>
    </c:if>
  </rl:listset>
</body>
</html>
