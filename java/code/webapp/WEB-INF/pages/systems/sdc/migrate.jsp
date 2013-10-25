<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2><bean:message key="sdc.table.migrate.header"/></h2>

    <html:form method="post" action="/systems/table/SystemMigrate.do?sid=${system.id}">
      <rhn:csrf />
      <html:hidden property="submitted" value="true"/>
    <table class="table">
      <tr>
        <th>
          <bean:message key="sdc.table.migrate.org"/>
        </th>
        <td>
          <html:select property="to_org">
            <html:option value="">-- None --</html:option>
            <c:forEach var="orgVar" items="${orgs}">
              <html:option value="${orgVar.name}">${orgVar.name}</html:option>
            </c:forEach>
          </html:select>
        </td>
      </tr>
    </table>

      <hr/>
        <div align="right">
          <html:submit>
            <bean:message key="sdc.table.migrate.migrate"/>
          </html:submit>
        </div>
    </html:form>
  </body>
</html:html>
