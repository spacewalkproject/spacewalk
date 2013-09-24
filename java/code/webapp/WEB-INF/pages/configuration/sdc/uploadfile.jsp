<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <head>
        <meta name="name" value="sdc.config.jsp.header" />
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <h2><bean:message key="sdcuploadfile.jsp.header"/></h2>
        <div class="page-summary">
            <p><bean:message key="sdcuploadfile.jsp.summary"/></p>
        </div>
        <div class="uploadfragment">
            <!-- Upload file to channel  -->
            <html:form
                styleClass="form-horizontal"
                action="/systems/details/configuration/addfiles/UploadFile.do?sid=${system.id}&csrf_token=${csrfToken}"
                enctype="multipart/form-data">
                <rhn:csrf />
                <rhn:submitted />
                <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/upload.jspf" %>
            </html:form>
        </div>
    </body>
</html>
