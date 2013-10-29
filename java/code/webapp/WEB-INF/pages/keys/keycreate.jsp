<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <body>
        <rhn:toolbar base="h1" icon="fa-info-circle" imgAlt="info.alt.img">
            <bean:message key="keycreate.jsp.toolbar"/>
        </rhn:toolbar>
        <bean:message key="keycreate.jsp.summary"/>
        <h2><bean:message key="keycreate.jsp.header2"/></h2>
        <html:form action="/keys/CryptoKeyCreate?csrf_token=${csrfToken}"
                   styleClass="form-horizontal"
                   enctype="multipart/form-data">
            <rhn:csrf />
            <html:hidden property="submitted" value="true"/>
            <html:hidden property="key_id" value="${cryptoKey.id}"/>
            <%@ include file="key-form.jspf" %>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="keycreate.jsp.submit"/>
                    </html:submit>
                </div>
            </div>
        </html:form>
    </body>
</html:html>

