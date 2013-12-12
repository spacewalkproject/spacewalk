<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >

<body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <br />

    <div class="toolbar-h2">
        <div class="toolbar">
            <span class="toolbar">
                <c:choose>
                    <c:when test="${not empty param.cnid}">
                        <a href="/rhn/systems/details/DeleteCrashNote.do?sid=${sid}&crid=${crid}&cnid=${cnid}">
                            <rhn:icon type="item-del" title="<bean:message key='toolbar.delete.note'/>" />
                            <bean:message key="toolbar.delete.note"/>
                        </a>
                        |
                    </c:when>
                </c:choose>
                <a href="/rhn/systems/details/SoftwareCrashDelete.do?crid=${crid}&sid=${sid}">
                    <rhn:icon type="item-del" title="<bean:message key='toolbar.delete.crash'/>" />
                    <bean:message key="toolbar.delete.crash"/>
                </a>

            </span>
        </div>
        <rhn:icon type="header-crash" title="<bean:message key='info.alt.img' />" />
        ${fn:escapeXml(crash.crash)}
    </div>

    <br />
    <br />
    <%@ include file="/WEB-INF/pages/common/fragments/systems/crash-header.jspf" %>

    <c:choose>
        <c:when test="${empty param.cnid}">
            <br />
            <bean:message key="details.crashnotes.createnote"/>
        </c:when>
    </c:choose>

    <html:form method="post" action="/systems/details/EditCrashNote.do">
        <rhn:csrf />
        <html:hidden property="submitted" value="true"/>
        <html:hidden property="sid" value="${sid}"/>
        <html:hidden property="crid" value="${crid}"/>
        <table class="details">
            <tr>
                <th><bean:message key="sdc.details.notes.subject"/></th>
                <td><html:text property="subject" maxlength="128" size="40" styleId="subject" /></td>
            </tr>
            <tr>
                <th><bean:message key="sdc.details.notes.details"/></th>
                <td><html:textarea property="note" cols="40" rows="6" styleId="note"/></td>
            </tr>
        </table>

        <hr/>
        <div class="text-right">
            <c:choose>
                <c:when test='${not empty cnid}'>
                    <html:submit property="edit_button"><bean:message key="edit_note.jsp.update"/></html:submit>
                </c:when>
                <c:otherwise>
                    <html:submit property="create_button"><bean:message key="edit_note.jsp.create"/></html:submit>
                </c:otherwise>
            </c:choose>
        </div>
        <html:hidden property="crid" value="${crid}"/>
        <html:hidden property="cnid" value="${cnid}"/>
    </html:form>
</body>
</html:html>
