<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <body>
        <rhn:toolbar base="h1" icon="header-info" imgAlt="info.alt.img">
            <bean:message key="certificate.jsp.toolbar"/>
        </rhn:toolbar>
        <p><bean:message key="certificate.jsp.summary"/></p>
        <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><bean:message key="certificate.jsp.header2"/></h4>
            </div>
            <div class="panel-body">
                <html:form action="/admin/config/CertificateConfig?csrf_token=${csrfToken}"
                           styleClass="form-horizontal"
                           enctype="multipart/form-data">
                    <rhn:csrf />
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="certfile">
                            <rhn:required-field key="certificate.jsp.cert_file"/>
                        </label>
                        <div class="col-lg-6">
                            <html:file property="cert_file" styleId="certfile" styleClass="form-control"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="certtext">
                            <rhn:required-field key="certificate.jsp.cert_text"/>
                        </label>
                        <div class="col-lg-6">
                            <html:textarea cols="80" rows="24" property="cert_text" styleClass="form-control"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <html:submit styleClass="btn btn-success">
                                <bean:message key="config.update"/>
                            </html:submit>
                        </div>
                    </div>
                    <html:hidden property="suite_id" value="${probeSuite.id}"/>
                    <html:hidden property="submitted" value="true"/>
                </html:form>
            </div>
        </div>
    </body>
</html:html>
