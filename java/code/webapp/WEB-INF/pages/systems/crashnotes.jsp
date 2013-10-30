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
                    <img src="/img/action-add.gif"
                         alt="<bean:message key="toolbar.create.crashnote"/>"
                         title="<bean:message key="toolbar.create.crashnote"/>" />
                    <bean:message key="toolbar.create.crashnote"/>
                </a>
                |
                <a href="/rhn/systems/details/SoftwareCrashDelete.do?crid=${crid}&sid=${sid}">
                    <img src="/img/action-del.gif"
                         alt="<bean:message key="toolbar.delete.crash"/>"
                         title="<bean:message key="toolbar.delete.crash"/>" />
                    <bean:message key="toolbar.delete.crash"/>
                </a>

            </span>
        </div>
        <img src="/img/rhn-icon-bug-ex.gif"
             alt="<bean:message key="info.alt.img"/>"
             title="<bean:message key="info.alt.img"/>"/>
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
