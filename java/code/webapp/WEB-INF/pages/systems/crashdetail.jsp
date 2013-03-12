<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html:html xhtml="true">
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

  <br/>
  <rhn:toolbar base="h2" img="/img/rhn-icon-bug-ex.gif" imgAlt="info.alt.img"
               deletionUrl="SoftwareCrashDelete.do?crid=${crid}&sid=${sid}"
               deletionType="crash">
    ${fn:escapeXml(crash.crash)}
  </rhn:toolbar>
  <h2><bean:message key="crashes.jsp.details"/></h2>

<div class="page-summary">
  <p><bean:message key="crashes.jsp.details.summary"/></p>
</div>

<%@ include file="/WEB-INF/pages/common/fragments/systems/crash_details.jspf" %>

<hr/>

<rhn:toolbar base="h2"
       creationUrl="/rhn/systems/details/EditCrashNote.do?sid=${system.id}&crid=${crid}"
       creationType="crashnote"
  >
  <bean:message key="details.crashnotes.header"/>
</rhn:toolbar>

<rhn:list pageList="${crashNotesList}" noDataText="details.crashnotes.nonotes">
    <rhn:listdisplay>
    <rhn:column header="sdc.details.notes.subject"
    sortProperty="subject" url="/rhn/systems/details/EditCrashNote.do?sid=${system.id}&crid=${crid}&cnid=${current.id}"> ${current.subject}
    </rhn:column>
    <rhn:column header="sdc.details.notes.details" sortProperty="note">
        ${current.note}
    </rhn:column>

    <rhn:column header="sdc.details.notes.updated" sortProperty="modified">
        ${current.modifiedString}
    </rhn:column>
    </rhn:listdisplay>
</rhn:list>

<hr/>
<h2><bean:message key="crashfiles.jsp.header"/></h2>

<rl:listset name="crashFileList">
    <rhn:csrf />
    <rl:list
         width="100%"
         styleclass="list"
         emptykey="crashes.jsp.nocrashfiles"
         alphabarcolumn="filename">

        <rl:decorator name="PageSizeDecorator"/>

        <rl:column headerkey="crashes.jsp.filename" bound="false"
            sortattr="filename"
            sortable="true"
			defaultsort="asc"
            filterattr="filename">
            <c:if test="${current.isUploaded}">
                <a href="${current.downloadPath}">
            </c:if>
                ${current.filename}
            <c:if test="${current.isUploaded}">
                </a>
            </c:if>
        </rl:column>

        <rl:column headerkey="crashes.jsp.path" bound="false"
            sortattr="path"
            sortable="true">
            ${current.path}
        </rl:column>

        <rl:column headerkey="crashes.jsp.filesize" bound="false"
            sortattr="filesize"
            sortable="true">
            ${current.filesizeString}
        </rl:column>

        <rl:column headerkey="lastModified" bound="false"
            sortattr="modified"
            sortable="true">
            ${current.modifiedString}
        </rl:column>
    </rl:list>
    <rl:csv
        name="crashFileList"
        exportColumns="filename,path,filesize,modified"
        header="${crash.crash}"/>
    <html:hidden property="crid" value="${crid}"/>
    <html:hidden property="sid" value="${sid}"/>
</rl:listset>

</body>
</html:html>
