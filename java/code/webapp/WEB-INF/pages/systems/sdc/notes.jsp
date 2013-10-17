<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <rhn:toolbar base="h2" icon="header-note"
           creationUrl="/rhn/systems/details/EditNote.do?sid=${system.id}"
           creationType="note">
      <bean:message key="sdc.details.notes.header"/>
    </rhn:toolbar>

    <p><bean:message key="sdc.details.notes.message"/></p>
    <rhn:list pageList="${requestScope.pageList}"
            noDataText="sdc.details.notes.nonotes">

      <rhn:listdisplay>

        <rhn:column header="sdc.details.notes.subject" width="35%" sortProperty="subject"
            url="/rhn/systems/details/EditNote.do?sid=${system.id}&nid=${current.id}">
          <c:out value="${current.subject}" escapeXml="true" />
        </rhn:column>

        <rhn:column header="sdc.details.notes.details" width="50%">
          <pre><c:out value="${current.note}" escapeXml="true" /></pre>
        </rhn:column>

        <rhn:column header="sdc.details.notes.updated" sortProperty="modified">
          ${current.modified}
        </rhn:column>

      </rhn:listdisplay>

    </rhn:list>

  </body>
</html:html>
