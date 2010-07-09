<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">

<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="cobbler.jsp.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
    <p>
        <bean:message key="cobbler.jsp.summary1"/>
    </p>
    <p>
        <bean:message key="cobbler.jsp.summary2"/>
    </p>
    <p>
        <bean:message key="cobbler.jsp.summary3"/>
    </p>
</div>
<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="cobbler.jsp.header2"/></h2>

<div>
<form action="/rhn/admin/config/Cobbler.do">
    <table class="details">
    <tr>
        <th>
            <bean:message key="cobbler.jsp.sync"/>
        </th>
        <td>
            <input type="submit" name="cobbler_sync" value="${rhn:localize('update')}" />
        </td>
    </tr>
    </table>
    <hr/>
<rhn:submitted/>
</form>
</div>

</body>
</html:html>

