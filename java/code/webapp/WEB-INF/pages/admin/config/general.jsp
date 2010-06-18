<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="general.jsp.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
    <p>
        <bean:message key="general.jsp.summary"/>
    </p>
</div>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="general.jsp.header2"/></h2>

<div>
<html:form action="/admin/config/GeneralConfig" method="post">
    <table class="details">
    <tr>
        <th>
            <label for="admin_email"><rhn:required-field key="general.jsp.admin_email"/></label>
        </th>
        <td>
            <html:text property="traceback_mail" size="32" styleId="admin_email" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="hostname"><rhn:required-field key="general.jsp.hostname"/></label>
        </th>
        <td>
            <html:text property="server|jabber_server" size="32" styleId="hostname" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="proxy"><bean:message key="general.jsp.proxy"/></label>
        </th>
        <td>
            <html:text property="server|satellite|http_proxy" size="32" styleId="proxy" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="proxy_user"><bean:message key="general.jsp.proxy_username"/></label>
        </th>
        <td>
            <html:text property="server|satellite|http_proxy_username" size="32" styleId="proxy_user" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="proxy_password"><bean:message key="general.jsp.proxy_password"/></label>
        </th>
        <td>
            <html:password property="server|satellite|http_proxy_password" size="32" styleId="proxy_password" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="proxy_password_confirm"><bean:message key="general.jsp.proxy_password_confirm"/></label>
        </th>
        <td>
            <html:password property="server|satellite|http_proxy_password_confirm" 
            size="32" styleId="proxy_password_confirm" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="mount_point"><bean:message key="general.jsp.mount_point"/></label>
        </th>
        <td>
            <html:text property="mount_point" size="32" styleId="mount_point" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="ssl_available"><bean:message key="general.jsp.defaultTo_ssl"/></label>
        </th>
        <td>
            <html:checkbox property="web|ssl_available" styleId="ssl_available" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="solaris"><bean:message key="general.jsp.solaris"/></label>
        </th>
        <td>
            <html:checkbox property="web|enable_solaris_support" styleId="solaris" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="disconnected"><bean:message key="general.jsp.disconnected"/></label>
        </th>
        <td>
            <html:checkbox property="disconnected" styleId="disconnected" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="is_monitoring_backend"><bean:message key="general.jsp.monitoring_backend"/></label>
        </th>
        <td>
            <html:checkbox property="web|is_monitoring_backend" styleId="is_monitoring_backend" />
        </td>
    </tr>
    </table>
    <hr/>
    <div align="right"><html:submit><bean:message key="config.update"/></html:submit></div>
    <html:hidden property="suite_id" value="${probeSuite.id}"/>
    <html:hidden property="submitted" value="true"/>
</html:form>
</div>

</body>
</html:html>

