<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-config_management.gif"
	           helpUrl="">
    <bean:message key="generalconfig.jsp.header1"/>
  </rhn:toolbar>



<div>
  <p>
    <bean:message key="generalconfig.jsp.summary"/>
  </p>
</div>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="generalconfig.jsp.header2"/></h2>

    <rhn:require acl="user_role(satellite_admin)">
    <html:form action="/admin/config/MonitoringConfig" method="POST">
      <table class="details">
        <tr>
            <th>
                <label for="is_monitoring_scout"><bean:message key="general.jsp.monitoring_scout"/></label>
            </th>
            <td>
                <html:checkbox property="is_monitoring_scout" styleId="is_monitoring_scout" />
            </td>
        </tr>
        <c:forEach items="${configList}" var="config">
          <tr>
            <th><label for="${config.name}">${config.description}</label></th>
            <td><input type="text" size="30" name="${config.name}" value="${config.value}" maxlength="255" styleId="${config.name}" /></td>
          </tr>
        </c:forEach>

      </table>

      <div align="right">
        <hr />
        <html:submit><bean:message key="generalconfig.jsp.update_config"/></html:submit>
        <input type="hidden" name="submitted" value="true" />
      </div>

    </html:form>
    </rhn:require>
    <rhn:require acl="not user_role(satellite_admin)">
        <bean:message key="monitoring.jsp.monitoringdisabled"/>
    </rhn:require>
</body>
</html>

