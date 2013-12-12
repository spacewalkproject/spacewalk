<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<html:html >
<body>
<br>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<div class="toolbar-h2">
  <div class="toolbar">
    <span class="toolbar">
      <a href="/rhn/systems/details/DeleteCustomData.do?sid=${sid}&cikid=${cikid}">
        <rhn:icon type="item-del" title="delete value" />delete value
      </a>
    </span>
  </div>
  <rhn:icon type="header-info" />
  <bean:message key="system.jsp.customkey.updatetitle"/>
</div>

  <hr />

  <form action="/rhn/systems/details/UpdateCustomData.do?sid=${system.id}&cikid=${cikid}" name="edit_token" method="post">
    <rhn:csrf />
    <table class="table">
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
        <td><fmt:formatDate pattern="yyyy-MM-dd hh:mm:ss" value="${created}"/> by ${creator}</td>
      </tr>

      <tr>
        <th><bean:message key="system.jsp.customkey.modified"/>:</th>
        <td><fmt:formatDate pattern="yyyy-MM-dd hh:mm:ss" value="${modified}"/> by ${modifier}</td>
      </tr>
    </table>

    <div class="text-right">
      <hr />

      <input type="submit" name="UpdateKey" value="Update Key" />

      <rhn:submitted/>
    </div>
  </form>

</div>

  </body>
</html:html>
