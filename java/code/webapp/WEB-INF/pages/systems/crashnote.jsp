<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >

<body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <rhn:toolbar base="h2" icon="header-crash" iconAlt="info.alt.img"
                 deletionUrl="DeleteCrashNote.do?sid=${sid}&crid=${crid}&cnid=${cnid}"
                 deletionType="note"
                 deletionAcl="formvar_exists(cnid)">
        ${fn:escapeXml(crash.crash)}
    </rhn:toolbar>

    <%@ include file="/WEB-INF/pages/common/fragments/systems/crash-header.jspf" %>

    <c:choose>
        <c:when test="${empty param.cnid}">
            <h3><bean:message key="details.crashnotes.createnote"/></h3>
        </c:when>
    </c:choose>

    <html:form styleClass="form-horizontal" method="post" action="/systems/details/EditCrashNote.do">
        <rhn:csrf />
        <html:hidden property="submitted" value="true"/>
        <html:hidden property="sid" value="${sid}"/>
        <html:hidden property="crid" value="${crid}"/>
        <div class="form-group">
            <label class="col-lg-3 control-label" for="subject"><bean:message key="sdc.details.notes.subject"/></label>
            <div class="col-lg-6"><html:text styleClass="form-control" property="subject" maxlength="128" size="40" styleId="subject" /></div>
        </div>
        <div class="form-group">
            <label class="col-lg-3 control-label" for="note"><bean:message key="sdc.details.notes.details"/></label>
            <div class="col-lg-6"><html:textarea styleClass="form-control" property="note" cols="40" rows="6" styleId="note"/></div>
        </div>

        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
            <c:choose>
                <c:when test='${not empty cnid}'>
                    <html:submit styleClass="btn btn-success" property="edit_button"><bean:message key="edit_note.jsp.update"/></html:submit>
                </c:when>
                <c:otherwise>
                    <html:submit styleClass="btn btn-success" property="create_button"><bean:message key="edit_note.jsp.create"/></html:submit>
                </c:otherwise>
            </c:choose>
            </div>
        </div>
        <html:hidden property="crid" value="${crid}"/>
        <html:hidden property="cnid" value="${cnid}"/>
    </html:form>
</body>
</html:html>
