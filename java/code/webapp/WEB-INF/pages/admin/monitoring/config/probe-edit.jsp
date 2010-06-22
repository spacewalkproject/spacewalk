<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
<body>

<script type="text/javascript" language="JavaScript">
<!--
function refreshNotifFields() {
  form = document.forms['probeEditForm'];
  form.notification_interval_min.disabled = !form.notification.checked;
  form.contact_group_id.disabled = !form.notification.checked;
  return true;
}
//-->
</script>

  <rhn:toolbar base="h1" img="/img/rhn-config_management.gif"
               helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-psuites">
    <bean:message key="probe-edit.jsp.header1" arg0="${probe.description}" arg1="${probeSuite.suiteName}" />
  </rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/probesuite_detail_edit.xml" 
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="probe-edit.jsp.header2"/></h2>
<html:form action="/monitoring/config/ProbeSuiteProbeEdit" method="POST">
  <table class="details">
    <tr>
      <th><bean:message key="probeedit.jsp.probecommand" /></th>
      <td colspan="3">${probe.command.description}</td>
    </tr>
    <c:if test='${not empty probe.command.systemRequirements}'>
    <tr>
      <th><bean:message key="probeedit.jsp.commandrequirements" /></th>
      <td colspan="3"><bean:message key="${probe.command.systemRequirements}"/></td>
    </tr>
    </c:if>
    <c:if test='${not empty probe.command.versionSupport}'>
    <tr>
      <th><bean:message key="probeedit.jsp.versionsupport" /></th>
      <td colspan="3">${probe.command.versionSupport}</td>
    </tr>
    </c:if>
    <tr>
      <th><label for="description"><bean:message key="probeedit.jsp.description" /></label></th>
      <td colspan="3"><html:text property="description" maxlength="100" size="50" styleId="description"/></td>
    </tr>
    <tr>
      <th><label for="notification"><bean:message key="probeedit.jsp.notification" /></label></th>
      <td colspan="3"><html:checkbox onclick="refreshNotifFields()" property="notification" styleId="notification"/></td>
    </tr>
      <tr>
        <th><label for="notifmin"><bean:message key="probeedit.jsp.notifmin" /></label></th>
        <td colspan="3">
            <html:select property="notification_interval_min" 
                  disabled="${not probeEditForm.map.notification}" styleId="notifmin">
              <html:options collection="intervals"
                property="value"
                labelProperty="label" />
            </html:select>
        </td>
      </tr>
      <tr>
        <th><label for="notifmethod"><bean:message key="probeedit.jsp.notifmethod" /></label></th>
        <td colspan="3"><html:select property="contact_group_id"
                  disabled="${not probeEditForm.map.notification}" styleId="notifmethod">
              <html:options collection="contactGroups"
                property="value"
                labelProperty="label" />
            </html:select>
        </td>
      </tr>
    <tr>
      <th><label for="checkinterval"><bean:message key="probeedit.jsp.checkinterval" /></label></th>
      <td colspan="3">
        <html:select property="check_interval_min" styleId="checkinterval">
              <html:options collection="intervals"
                property="value"
                labelProperty="label" />
        </html:select>
      </td>
    </tr>
    
    <%@ include file="/WEB-INF/pages/common/fragments/probes/render-param-value-list.jspf" %>
    <tr>
      <td></td>
      <td colspan="3" align="right"><html:submit><bean:message key="probedit.jsp.updateprobe"/></html:submit></td>
    </tr>
  </table>
  <html:hidden property="suite_id" value="${param.suite_id}"/>
  <html:hidden property="probe_id" value="${probe.id}"/>
  <html:hidden property="submitted" value="true"/>
</html:form>
           
</body>
</html>
