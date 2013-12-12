<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <c:choose>
            <c:when test="${empty param.nid}">
                <rhn:toolbar base="h2" icon="header-note">
                    <bean:message key="sdc.details.notes.header"/>
                </rhn:toolbar>
                <c:set var="urlParam" scope="request" value="sid=${system.id}"/>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h2" icon="header-note"
                             deletionUrl="/rhn/systems/details/DeleteNote.do?sid=${system.id}&nid=${n.id}"
                             deletionType="note">
                    <bean:message key="sdc.details.notes.header"/>
                </rhn:toolbar>
                <c:set var="urlParam" scope="request" value="sid=${system.id}&nid=${n.id}"/>
            </c:otherwise>
        </c:choose>
        <html:form method="post"
                   styleClass="form-horizontal"
                   action="/systems/details/EditNote.do?${urlParam}">
            <rhn:csrf />
            <html:hidden property="submitted" value="true"/>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="subject">
                    <bean:message key="sdc.details.notes.subject"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="subject" maxlength="128" size="40" styleId="subject" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="note">
                    <bean:message key="sdc.details.notes.details"/>
                </label>
                <div class="col-lg-6">
                    <html:textarea property="note" cols="40" rows="6" styleId="note" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <c:choose>
                        <c:when test='${not empty n.id}'>
                            <html:submit property="edit_button" styleClass="btn btn-success">
                                <bean:message key="edit_note.jsp.update"/>
                            </html:submit>
                        </c:when>
                        <c:otherwise>
                            <html:submit property="create_button" styleClass="btn btn-success">
                                <bean:message key="edit_note.jsp.create"/>
                            </html:submit>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </html:form>
    </body>
</html:html>
