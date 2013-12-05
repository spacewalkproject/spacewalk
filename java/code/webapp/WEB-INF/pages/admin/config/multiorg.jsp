<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<body>
<rhn:toolbar base="h1" icon="fa-info-circle" imgAlt="info.alt.img">
  <bean:message key="general.jsp.org.toolbar"/>
</rhn:toolbar>

        <p><bean:message key="general.jsp.org.summary1"/></p>
        <p><bean:message key="general.jsp.org.summary2"/></p>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<div class="panel panel-default">
  <div class="panel-heading">
    <h4><bean:message key="general.jsp.org.header"/></h4>
  </div>
  <div class="panel-body">
    <p><bean:message key="general.jsp.org.summary3"/></p>
    <table class="table">
    	<tr>
    		<td><i class="fa fa-sitemap fa-3x"></i></td>
    		<td><bean:message key="general.jsp.org.tbl.header1"/>:</td>
        <td>
          <p>
          <bean:message key="general.jsp.org.tbl.description1"/>
          </p>
          <p>
          <a href="/rhn/admin/multiorg/Organizations.do"><bean:message key="general.jsp.org.tbl.link1"/></a>.
          </p>
        </td>
    	</tr>
    	<tr>
    		<td><i class="fa fa-list-alt fa-3x"></i></td>
    		<td><bean:message key="general.jsp.org.tbl.header2"/>:</td>
        <td>
          <p>
          <bean:message key="general.jsp.org.tbl.description2"/>
          </p>
          <p>
          <a href="/rhn/admin/multiorg/SoftwareEntitlements.do"><bean:message key="general.jsp.org.tbl.link2"/></a>.
          </p>
        </td>
    	</tr>
    	<tr>
    		<td><i class="fa fa-group fa-3x"></i></td>
    		<td><bean:message key="general.jsp.org.tbl.header3"/>:</td>
        <td>
          <p>
          <bean:message key="general.jsp.org.tbl.description3"/>
          </p>
          <p>
          <a href="/rhn/admin/multiorg/Users.do"><bean:message key="general.jsp.org.tbl.link3"/></a>.
          </p>
        </td>
    	</tr>
      <tr>
        <td colspan="3">
          <p>
            <small>
              <bean:message key="general.jsp.org.summary4"/><a href="/rhn/help/reference/index.jsp">
              <bean:message key="general.jsp.org.tbl.link4"/></a>.
            </small>
          </p>
        </td>
      </tr>
    </table>

  </div>
</div>

</body>
</html:html>

