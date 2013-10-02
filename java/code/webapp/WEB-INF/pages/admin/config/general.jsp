<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
    <body>
        <rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
            <bean:message key="general.jsp.toolbar"/>
        </rhn:toolbar>
        <p><bean:message key="general.jsp.summary"/></p>
        <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <h2><bean:message key="general.jsp.header2"/></h2>
        <html:form action="/admin/config/GeneralConfig"
                   styleClass="form-horizontal"
                   method="post">
            <rhn:csrf />
            <div class="form-group">
                <label for="admin_email" class="col-lg-3 control-label">
                    <rhn:required-field key="general.jsp.admin_email"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="traceback_mail"
                               styleClass="form-control"
                               size="32" styleId="admin_email" />
                </div>
            </div>
            <div class="form-group">
                <label for="hostname" class="col-lg-3 control-label">
                    <rhn:required-field key="general.jsp.hostname"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="server|jabber_server"
                               styleClass="form-control"
                               size="32" styleId="hostname" />
                </div>
            </div>
            <div class="form-group">
                <label for="proxy" class="col-lg-3 control-label">
                    <bean:message key="general.jsp.proxy"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="server|satellite|http_proxy"
                               styleClass="form-control"
                               size="32" styleId="proxy" />
                </div>
            </div>
            <div class="form-group">
                <label for="proxy_user" class="col-lg-3 control-label">
                    <bean:message key="general.jsp.proxy_username"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="server|satellite|http_proxy_username"
                               styleClass="form-control"
                               size="32" styleId="proxy_user" />
                </div>
            </div>
            <div class="form-group">
                <label for="proxy_password" class="col-lg-3 control-label">
                    <bean:message key="general.jsp.proxy_password"/>:
                </label>
                <div class="col-lg-6">
                    <html:password property="server|satellite|http_proxy_password"
                                   styleClass="form-control"
                                   size="32" styleId="proxy_password" />
                </div>
            </div>
            <div class="form-group">
                <label for="proxy_password_confirm" class="col-lg-3 control-label">
                    <bean:message key="general.jsp.proxy_password_confirm"/>:
                </label>
                <div class="col-lg-6">
                            <html:password property="server|satellite|http_proxy_password_confirm"
                                           styleClass="form-control"
                                           size="32" styleId="proxy_password_confirm" />
                </div>
            </div>
            <div class="form-group">
                <label for="mount_point" class="col-lg-3 control-label">
                    <bean:message key="general.jsp.mount_point"/>:
                </label>
                <div class="col-lg-6">
                    <html:text property="mount_point" size="32"
                               styleClass="form-control"
                               styleId="mount_point" />
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <label for="ssl_available">
                        <html:checkbox property="web|ssl_available" styleId="ssl_available" />
                        <bean:message key="general.jsp.defaultTo_ssl"/>
                    </label>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <label for="solaris">
                        <html:checkbox property="web|enable_solaris_support" styleId="solaris" />
                        <bean:message key="general.jsp.solaris"/>
                    </label>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <label for="disconnected">
                        <html:checkbox property="disconnected" styleId="disconnected" />
                        <bean:message key="general.jsp.disconnected"/>
                    </label>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <label for="is_monitoring_backend">
                        <html:checkbox property="web|is_monitoring_backend" styleId="is_monitoring_backend" />
                        <bean:message key="general.jsp.monitoring_backend"/>
                    </label>
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

