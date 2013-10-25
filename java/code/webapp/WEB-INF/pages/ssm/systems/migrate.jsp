<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <bean:message key="ssm.migrate.systems.header" />
</h2>
<p><bean:message key="ssm.migrate.systems.summary" /></p>
<c:set var="notSelectable" value="true"/>
<c:set var="showLastCheckin" value="true"/>
<c:set var="noPackages" value="true"/>
<c:set var="noErrata" value="true"/>

  <c:choose>
  <c:when test="${trustedOrgs == 0}">
    <strong><bean:message key="ssm.migrate.systems.notrust"/></strong>
  </c:when>
  <c:otherwise>
  <html:form method="post" action="/systems/ssm/MigrateSystems.do">
    <rhn:csrf />
    <rhn:submitted />
    <table class="table">
      <tr>
        <th>
          <bean:message key="ssm.migrate.systems.org"/>
        </th>
        <td>
          <html:select property="org">
            <html:option value="">-- None --</html:option>
            <c:forEach var="o" items="${orgs}">
              <html:option value="${o.name}">${o.name}</html:option>
            </c:forEach>
          </html:select>
        </td>
        <td class="text-right">
          <input type ="submit" name="dispatch" value="${rhn:localize('ssm.migrate.systems.confirmbutton')}"/>
        </td>
      </tr>
    </table>
  </html:form>
  </c:otherwise>
  </c:choose>

<rl:listset name="systemListSet" legend="system">
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
<%--
	<div class="text-right">
      <hr />
      <input type ="submit" name="dispatch" value="${rhn:localize('ssm.migrate.systems.confirmbutton')}"/>
    </div>
--%>
</rl:listset>


</body>
</html>

