<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">
<body>
<br>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<div class="toolbar-h2">
  <div class="toolbar">
    <span class="toolbar">
      <a href="/rhn/systems/details/DeleteCustomData.do?sid=${sid}&cikid=${cikid}">
        <img src="/img/action-del.gif" alt="delete value" title="delete value" />delete value
      </a>
    </span>
  </div>
  <img src="/img/rhn-icon-info.gif" alt="" />
  <bean:message key="system.jsp.customkey.updatetitle"/>
</div>

  <hr />

  <form action="/rhn/systems/details/UpdateCustomData.do?sid=${system.id}&cikid=${cikid}" name="edit_token" method="post">
    <table class="details">
      <tr>
        <th><bean:message key="system.jsp.customkey.keylabel"/>:</th>
        <td>${label}</td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.value"/>:</th>
        <td>
          <textarea wrap="virtual" rows="6" cols="50" name="value"><c:out value="${value}" /></textarea>
        </td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.created"/>:</th>
        <td>${created} by ${creator}</td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.modified"/>:</th>
        <td>${modified} by ${modifier}</td>
      </tr>
    </table>

    <div align="right">
      <hr />

      <input type="submit" name="UpdateKey" value="Update Key" />

      <rhn:submitted/>
    </div>
  </form>

</div>

  </body>
</html:html>
