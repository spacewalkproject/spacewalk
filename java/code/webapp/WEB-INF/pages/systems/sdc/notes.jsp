<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <rhn:toolbar base="h2" img="/img/rhn-icon-note.gif"
           creationUrl="/rhn/systems/details/EditNote.do?sid=${system.id}"
           creationType="note"
      >
      <bean:message key="sdc.details.notes.header"/>
    </rhn:toolbar>

    <div class="page-summary">
      <p><bean:message key="sdc.details.notes.message"/></p>
    </div>
    <rhn:list pageList="${requestScope.pageList}"
            noDataText="sdc.details.notes.nonotes">

      <rhn:listdisplay>

        <rhn:column header="sdc.details.notes.subject" width="35%" sortProperty="subject"
            url="/rhn/systems/details/EditNote.do?sid=${system.id}&nid=${current.id}">
          ${current.subject}
        </rhn:column>

        <rhn:column header="sdc.details.notes.details" width="50%">
          <pre>${current.note}</pre>
        </rhn:column>

        <rhn:column header="sdc.details.notes.updated" sortProperty="modified">
          ${current.modified}
        </rhn:column>

      </rhn:listdisplay>

    </rhn:list>


  </body>
</html:html>
