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
  <bean:message key="certificate.jsp.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
    <p>
        <bean:message key="certificate.jsp.summary"/>
    </p>
</div>


<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="certificate.jsp.header2"/></h2>

<div>
<html:form action="/admin/config/CertificateConfig" enctype="multipart/form-data">
    <table class="details">
    <tr>
        <th>
            <rhn:required-field key="certificate.jsp.cert_file"/>
        </th>
        <td>
            <html:file property="cert_file"/>
        </td>
    </tr>
    <tr>
        <th>
            <rhn:required-field key="certificate.jsp.cert_text"/>
        </th>
        <td>
            <html:textarea cols="80" rows="24" property="cert_text" />
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

