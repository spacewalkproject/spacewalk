<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="fa-rocket" imgAlt="system.common.kickstartAlt"
                     deletionUrl="/rhn/systems/provisioning/preservation/PreservationListDeleteSingle.do?file_list_id=${fileList.id}"
                     deletionType="filelist">
            <bean:message key="preservation_edit.jsp.toolbar"/>
        </rhn:toolbar>

        <bean:message key="preservation_edit.jsp.summary"/>
        <h2><bean:message key="preservation_edit.jsp.header2"/></h2>
        <html:form action="/systems/provisioning/preservation/PreservationListEdit"
                   styleClass="form-horizontal"
                   method="POST">
            <rhn:csrf />
            <%@ include file="preservation-form.jspf" %>
            <html:hidden property="submitted" value="true"/>
            <html:hidden property="file_list_id" value="${fileList.id}"/>

            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="preservationlist.jsp.updatelist"/>
                    </html:submit>
                </div>
            </div>
        </html:form>
    </body>
</html>

