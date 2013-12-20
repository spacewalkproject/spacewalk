<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
<body>
<br>

<div>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
  <div class="toolbar-h2">
    <div class="toolbar"></div>
      <rhn:icon type="system-warn" />
      <bean:message key="system.jsp.customdata.deletetitle"/>
    </div>

      <div class="page-summary">
        <p><bean:message key="system.jsp.customdata.removemsg"/></p>
      </div>

      <hr />

      <form action="/rhn/systems/details/DeleteCustomData.do?sid=${system.id}&cikid=${cikid}" name="edit_token" method="post">
        <rhn:csrf />
        <table class="details">
          <tr>
            <th><bean:message key="system.jsp.customdata.keylabel"/>:</th>
            <td>${label}</td>
          </tr>

          <tr>
            <th><bean:message key="system.jsp.customdata.description"/>:</th>
            <td><pre>${description}</pre></td>
          </tr>

          <tr>
            <th><bean:message key="system.jsp.customdata.created"/>:</th>
            <td>${created} by ${creator}</td>
          </tr>

          <tr>
            <th><bean:message key="system.jsp.customdata.lastmodified"/>:</th>
            <td>${lastModified} by ${lastModifier}</td>
          </tr>

        </table>

        <div class="text-right">
          <hr />

          <input type="submit" name="RemoveValue" value="${rhn:localize('system.jsp.customdata.removevalue')}"  />

          <rhn:submitted/>
        </div>
      </form>

    </div>

  </body>
</html:html>
