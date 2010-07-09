<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
  <bean:message key="general.jsp.org.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
        <p><bean:message key="general.jsp.org.summary1"/></p>
        <p><bean:message key="general.jsp.org.summary2"/></p>
</div>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="general.jsp.org.header"/></h2>
<div>
<p><bean:message key="general.jsp.org.summary3"/></p>

<table class="ssm-overview">
	<tr>
		<td><img src="/img/rhn-icon-org.gif"/></td>
		<th><bean:message key="general.jsp.org.tbl.header1"/>:</th>
                <td>
                  <p>
                  <bean:message key="general.jsp.org.tbl.description1"/>
                  <br>
                  <a href="/rhn/admin/multiorg/Organizations.do"><bean:message key="general.jsp.org.tbl.link1"/></a>.
                  </p>
                </td>
	</tr>
	<tr>
		<td><img src="/img/rhn-icon-channels.gif"/></td>
		<th><bean:message key="general.jsp.org.tbl.header2"/>:</th>
                <td>
                  <p>
                  <bean:message key="general.jsp.org.tbl.description2"/>
                  <br>
                  <a href="/rhn/admin/multiorg/SoftwareEntitlements.do"><bean:message key="general.jsp.org.tbl.link2"/></a>.
                  </p>
                </td>
	</tr>
	<tr>
		<td><img src="/img/rhn-icon-users.gif"/></td>
		<th><bean:message key="general.jsp.org.tbl.header3"/>:</th>
                <td>
                  <p>
                  <bean:message key="general.jsp.org.tbl.description3"/>
                  <br>
                  <a href="/rhn/admin/multiorg/Users.do"><bean:message key="general.jsp.org.tbl.link3"/></a>.
                  </p>
                </td>
	</tr>	
</table>

<p><bean:message key="general.jsp.org.summary4"/><a href="/rhn/help/reference/index.jsp">
   <bean:message key="general.jsp.org.tbl.link4"/></a>.
</p>

</div>

</body>
</html:html>

