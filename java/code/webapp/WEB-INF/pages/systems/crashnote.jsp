<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">

  <body>

    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <c:choose>
      <c:when test="${empty param.cnid}">
        <rhn:toolbar base="h2" img="/img/rhn-icon-note.gif">
          <bean:message key="crashes.jsp.details"/>
        </rhn:toolbar>
        <c:set var="urlParam" scope="request" value="sid=${system.id}&crid=${crid}"/>
      </c:when>
      <c:otherwise>
        <rhn:toolbar base="h2" img="/img/rhn-icon-note.gif"
            deletionUrl="/rhn/systems/details/DeleteCrashNote.do?sid=${system.id}&crid=${crid}&cnid=${cnid}"
            deletionType="note">
          <bean:message key="crashes.jsp.details"/>
        </rhn:toolbar>
        <c:set var="urlParam" scope="request" value="sid=${system.id}&crid=${crid}&cnid=${cnid}"/>
      </c:otherwise>
    </c:choose>

<div class="page-summary">
  <p><bean:message key="crashes.jsp.details.summary"/></p>
</div>

<%@ include file="/WEB-INF/pages/common/fragments/systems/crash_details.jspf" %>

<hr/>

    <h2><bean:message key="crashnotes.jsp.header"/></h2>
    <html:form method="post" action="/systems/details/EditCrashNote.do?${urlParam}">
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
           <c:when test='${not empty cnid}'>
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
      <html:hidden property="crid" value="${crid}"/>
      <html:hidden property="cnid" value="${cnid}"/>
    </html:form>

  </body>
</html:html>
