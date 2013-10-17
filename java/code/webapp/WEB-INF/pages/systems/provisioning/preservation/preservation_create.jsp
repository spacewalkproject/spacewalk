<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <body>
        <rhn:toolbar base="h1" icon="icon-info-sign" imgAlt="info.alt.img">
            <bean:message key="preservation_create.jsp.toolbar"/>
        </rhn:toolbar>

        <bean:message key="preservation_edit.jsp.summary"/>
        <h2><bean:message key="preservation_create.jsp.header2"/></h2>
        <div>
            <html:form action="/systems/provisioning/preservation/PreservationListCreate"
                       styleClass="form-horizontal"
                       method="post">
                <rhn:csrf />
                <html:hidden property="submitted" value="true"/>
                <html:hidden property="file_list_id" value="${fileList.id}"/>

                <%@ include file="preservation-form.jspf" %>

                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <html:submit styleClass="btn btn-success">
                            <bean:message key="preservationlist.jsp.createlist"/>
                        </html:submit>
                    </div>
                </div>
            </html:form>
        </div>
    </body>
</html:html>

