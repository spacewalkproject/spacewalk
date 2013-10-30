<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2>
      <img src="/img/rhn-icon-note.gif" alt="" /><bean:message key="sdc.details.notes.delete.header"/>
   </h2>
    <div class="page-summary">
      <p><bean:message key="sdc.details.notes.delete.confirm"/></p>
    </div>
    <html:form method="post" action="/systems/details/DeleteNote.do?sid=${system.id}&nid=${n.id}">
      <rhn:csrf />
      <html:hidden property="submitted" value="true"/>
    <table class="details">
      <tr>
        <th>
          <bean:message key="sdc.details.notes.subject"/>
        </th>
        <td>
          ${subject}
        </td>
      </tr>
      <tr>
        <th>
          <bean:message key="sdc.details.notes.details"/>
        </th>
        <td>
          ${note}
    </table>

      <hr/>
        <div class="text-right">
          <html:submit>
            <bean:message key="sdc.details.notes.delete"/>
          </html:submit>
        </div>
    </html:form>

  </body>
</html:html>
