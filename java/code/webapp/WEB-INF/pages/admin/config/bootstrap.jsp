<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="bootstrap.jsp.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
    <p>
        <bean:message key="bootstrap.jsp.summary"/>
    </p>
</div>


<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="bootstrap.jsp.header2"/></h2>

<div>
<html:form action="/admin/config/BootstrapConfig" enctype="multipart/form-data">
    <table class="details">
    <tr>
        <th>
            <label for="hostname"><rhn:required-field key="bootstrap.jsp.hostname"/>:</label>
        </th>
        <td>
            <html:text size="32" property="hostname" styleId="hostname" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="ssl-cert"><rhn:required-field key="bootstrap.jsp.ssl-cert"/>:</label>
        </th>
        <td>
            <html:text size="32" property="ssl-cert" styleId="ssl-cert" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="ssl"><bean:message key="bootstrap.jsp.ssl"/></label>
        </th>
        <td>
            <html:checkbox property="ssl" styleId="ssl" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="gpg"><bean:message key="bootstrap.jsp.gpg"/></label>
        </th>
        <td>
            <html:checkbox property="gpg" styleId="gpg" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="allow-config-actions"><bean:message key="bootstrap.jsp.allow-config-actions"/></label>
        </th>
        <td>
            <html:checkbox property="allow-config-actions" styleId="allow-config-actions"/>
        </td>
    </tr>
    <tr>
        <th>
            <label for="allow-remote-commands"><bean:message key="bootstrap.jsp.allow-remote-commands"/></label>
        </th>
        <td>
            <html:checkbox property="allow-remote-commands" styleId="allow-remote-commands" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="http-proxy"><bean:message key="bootstrap.jsp.http-proxy"/></label>
        </th>
        <td>
            <html:text size="32" property="http-proxy" styleId="http-proxy" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="http-proxy-username"><bean:message key="bootstrap.jsp.http-proxy-username"/></label>
        </th>
        <td>
            <html:text size="32" property="http-proxy-username" styleId="http-proxy-username" />
        </td>
    </tr>
    <tr>
        <th>
            <label for="http-proxy-password"><bean:message key="bootstrap.jsp.http-proxy-password"/></label>
        </th>
        <td>
            <html:text size="32" property="http-proxy-password" styleId="http-proxy-password" />
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

