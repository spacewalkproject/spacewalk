<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

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
            <rhn:required-field key="bootstrap.jsp.hostname"/>:
        </th>
        <td>
            <html:text size="32" property="hostname" />
        </td>
    </tr>
    <tr>
        <th>
            <rhn:required-field key="bootstrap.jsp.ssl-cert"/>:
        </th>
        <td>
            <html:text size="32" property="ssl-cert" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="bootstrap.jsp.ssl"/>
        </th>
        <td>
            <html:checkbox property="ssl" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="bootstrap.jsp.gpg"/>
        </th>
        <td>
            <html:checkbox property="gpg" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="bootstrap.jsp.allow-config-actions"/>
        </th>
        <td>
            <html:checkbox property="allow-config-actions" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="bootstrap.jsp.allow-remote-commands"/>
        </th>
        <td>
            <html:checkbox property="allow-remote-commands"/>
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="bootstrap.jsp.http-proxy"/>
        </th>
        <td>
            <html:text size="32" property="http-proxy" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="bootstrap.jsp.http-proxy-username"/>
        </th>
        <td>
            <html:text size="32" property="http-proxy-username" />
        </td>
    </tr>
    <tr>
        <th>
            <bean:message key="bootstrap.jsp.http-proxy-password"/>
        </th>
        <td>
            <html:text size="32" property="http-proxy-password" />
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

