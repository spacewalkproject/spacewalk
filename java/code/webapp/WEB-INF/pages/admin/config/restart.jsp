<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">

<head>
	<c:if test="${requestScope.restart == 'true'}">
	    <script src="/javascript/restart.js" type="text/javascript"> </script>
	</c:if>
</head>
<body  <c:if test="${requestScope.restart == 'true'}">onload="checkConnection(${requestScope.restartDelay})"</c:if> >
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="restart.jsp.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
    <p>
        <bean:message key="restart.jsp.summary"/>
    </p>
</div>
<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="restart.jsp.header2"/></h2>

<div>
<html:form action="/admin/config/Restart">
    <table class="details">
    <tr>
        <th>
            <label for="restart"><bean:message key="restart.jsp.restart_satellite"/></label>
        </th>
        <td>
            <html:checkbox property="restart" styleId="restart" />
        </td>
    </tr>

    </table>
    <hr/>
    <div align="right"><html:submit><bean:message key="restart.jsp.restart"/></html:submit></div>
<rhn:submitted/>
</html:form>
</div>

</body>
</html:html>

