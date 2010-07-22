<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2><bean:message key="sdc.details.migrate.header"/></h2>

    <html:form method="post" action="/systems/details/SystemMigrate.do?sid=${system.id}">
      <html:hidden property="submitted" value="true"/>
    <table class="details">
      <tr>
        <th>
          <bean:message key="sdc.details.migrate.org"/>
        </th>
        <td>
          <html:select property="to_org">
            <html:option value="">-- None --</html:option>
            <c:forEach var="org" items="${orgs}">
              <html:option value="${org.name}">${org.name}</html:option>
            </c:forEach>
          </html:select>
        </td>
      </tr>
    </table>

      <hr/>
        <div align="right">
          <html:submit>
            <bean:message key="sdc.details.migrate.migrate"/>
          </html:submit>
        </div>
    </html:form>
  </body>
</html:html>
