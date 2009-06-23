<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>

<html:errors/>
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

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
            <rhn:required-field key="general.jsp.admin_email"/>
        </th>
        <td>
            <html:text property="traceback_mail" size="32" />
        </td>
    </tr>
    <tr>
        <th>
            <rhn:required-field key="general.jsp.hostname"/>
        </th>
        <td>
            <html:text property="server|jabber_server" size="32" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.proxy"/>
        </th>
        <td>
            <html:text property="server|satellite|http_proxy" size="32" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.proxy_username"/>
        </th>
        <td>
            <html:text property="server|satellite|http_proxy_username" size="32" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.proxy_password"/>
        </th>
        <td>
            <html:password property="server|satellite|http_proxy_password" size="32" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.proxy_password_confirm"/>
        </th>
        <td>
            <html:password property="server|satellite|http_proxy_password_confirm" 
            size="32" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.mount_point"/>
        </th>
        <td>
            <html:text property="mount_point" size="32" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.defaultTo_ssl"/>
        </th>
        <td>
            <html:checkbox property="web|ssl_available" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.solaris"/>
        </th>
        <td>
            <html:checkbox property="web|enable_solaris_support" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.disconnected"/>
        </th>
        <td>
            <html:checkbox property="disconnected" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="general.jsp.monitoring_backend"/>
        </th>
        <td>
            <html:checkbox property="web|is_monitoring_backend" />
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

