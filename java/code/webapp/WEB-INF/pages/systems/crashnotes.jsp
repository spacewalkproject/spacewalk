<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html:html >
<body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <br/>

    <div class="toolbar-h2">
        <div class="toolbar">
            <span class="toolbar">
                <a href="/rhn/systems/details/EditCrashNote.do?crid=${crid}&sid=${sid}">
                    <i class="fa fa-plus-circle text-success" title="<bean:message key='toolbar.create.crashnote'/>"></i>
                    <bean:message key="toolbar.create.crashnote"/>
                </a>
                |
                <a href="/rhn/systems/details/SoftwareCrashDelete.do?crid=${crid}&sid=${sid}">
                    <i class="fa fa-minus-circle text-danger" title="<bean:message key='toolbar.delete.crash'/>"></i>
                    <bean:message key="toolbar.delete.crash"/>
                </a>

            </span>
        </div>
        <i class="fa spacewalk-icon-bug-ex" title="<bean:message key='info.alt.img'/>"></i>
        ${fn:escapeXml(crash.crash)}
    </div>

    <br />
    <br />
    <%@ include file="/WEB-INF/pages/common/fragments/systems/crash-header.jspf" %>

    <br />
    <rhn:list pageList="${crashNotesList}" noDataText="details.crashnotes.nonotes">
        <rhn:listdisplay>

        <rhn:column header="sdc.details.notes.subject"
                    sortProperty="subject"
                    url="/rhn/systems/details/EditCrashNote.do?sid=${system.id}&crid=${crid}&cnid=${current.id}">
            ${current.subject}
        </rhn:column>

        <rhn:column header="sdc.details.notes.details" sortProperty="note">
            ${current.note}
        </rhn:column>

        <rhn:column header="sdc.details.notes.updated" sortProperty="modified">
            ${current.modifiedString}
        </rhn:column>

        </rhn:listdisplay>
    </rhn:list>
</body>
</html:html>
