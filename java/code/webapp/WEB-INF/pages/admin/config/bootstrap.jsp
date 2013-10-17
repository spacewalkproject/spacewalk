<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <body>
        <rhn:toolbar base="h1" icon="icon-info-sign" imgAlt="info.alt.img">
            <bean:message key="bootstrap.jsp.toolbar"/>
        </rhn:toolbar>
        <div class="page-summary">
            <p><bean:message key="bootstrap.jsp.summary"/></p>
        </div>
        <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <h2><bean:message key="bootstrap.jsp.header2"/></h2>
        <html:form action="/admin/config/BootstrapConfig?csrf_token=${csrfToken}"
                   styleClass="form-horizontal"
                   enctype="multipart/form-data">
            <rhn:csrf />
            <div class="form-group">
                <label for="hostname" class="col-lg-3 control-label">
                    <rhn:required-field key="bootstrap.jsp.hostname"/>:
                </label>
                <div class="col-lg-6">
                    <html:text size="32" property="hostname" styleId="hostname" styleClass="form-control" />
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="ssl-cert">
                    <rhn:required-field key="bootstrap.jsp.ssl-cert"/>:
                </label>
                <div class="col-lg-6">
                    <html:text size="32" property="ssl-cert" styleId="ssl-cert" styleClass="form-control" />
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <html:checkbox property="ssl" styleId="ssl" />
                            <bean:message key="bootstrap.jsp.ssl"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <html:checkbox property="gpg" styleId="gpg" />
                            <bean:message key="bootstrap.jsp.gpg"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <html:checkbox property="allow-config-actions" styleId="allow-config-actions"/>
                            <bean:message key="bootstrap.jsp.allow-config-actions"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <html:checkbox property="allow-remote-commands" styleId="allow-remote-commands" />
                            <bean:message key="bootstrap.jsp.allow-remote-commands"/>
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="http-proxy">
                    <bean:message key="bootstrap.jsp.http-proxy"/>
                </label>
                <div class="col-lg-6">
                    <html:text size="32" property="http-proxy" styleId="http-proxy" styleClass="form-control" />
                </div>
            </div>
            <div class="form-group">
                <label for="http-proxy-username" class="col-lg-3 control-label">
                    <bean:message key="bootstrap.jsp.http-proxy-username"/>
                </label>
                <div class="col-lg-6">
                    <html:text size="32" property="http-proxy-username" styleClass="form-control" styleId="http-proxy-username" />
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="http-proxy-password">
                    <bean:message key="bootstrap.jsp.http-proxy-password"/>
                </label>
                <div class="col-lg-6">
                    <html:text size="32" property="http-proxy-password" styleId="http-proxy-password" styleClass="form-control" />
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
    </body>
</html:html>

