<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">

  <body>

    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <c:choose>
      <c:when test="${empty param.nid}">
        <rhn:toolbar base="h2" img="/img/rhn-icon-note.gif">
          <bean:message key="sdc.details.notes.header"/>
        </rhn:toolbar>
        <c:set var="urlParam" scope="request" value="sid=${system.id}"/>
      </c:when>
      <c:otherwise>
        <rhn:toolbar base="h2" img="/img/rhn-icon-note.gif"
            deletionUrl="/rhn/systems/details/DeleteNote.do?sid=${system.id}&nid=${n.id}"
            deletionType="note">
          <bean:message key="sdc.details.notes.header"/>
        </rhn:toolbar>
        <c:set var="urlParam" scope="request" value="sid=${system.id}&nid=${n.id}"/>
      </c:otherwise>
    </c:choose>

    <html:form method="post" action="/systems/details/EditNote.do?${urlParam}">
      <rhn:csrf />
      <html:hidden property="submitted" value="true"/>
      <table class="details">
        <tr>
          <th>
            <bean:message key="sdc.details.notes.subject"/>
          </th>
          <td>
            <html:text property="subject" maxlength="128" size="40" styleId="subject" />
          </td>
        </tr>
        <tr>
          <th>
            <bean:message key="sdc.details.notes.details"/>
          </th>
          <td>
            <html:textarea property="note" cols="40" rows="6" styleId="note"/>
          </td>
        </tr>
      </table>

      <hr/>
      <div align="right">
        <c:choose>
           <c:when test='${not empty n.id}'>
           <html:submit property="edit_button">
             <bean:message key="edit_note.jsp.update"/>
           </html:submit>
           </c:when>
           <c:otherwise>
           <html:submit property="create_button">
             <bean:message key="edit_note.jsp.create"/>
           </html:submit>
           </c:otherwise>
        </c:choose>
      </div>
    </html:form>

  </body>
</html:html>
