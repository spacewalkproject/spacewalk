<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
    <head>
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

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-system"
    deletionUrl="/rhn/systems/details/probes/ProbeDelete.do?probe_id=${probe.id}&amp;sid=${system.id}"
    deletionType="probe">
 <bean:message key="probeedit.jsp.editprobe" />
</rhn:toolbar>
<html:form action="/systems/details/probes/ProbeEdit" method="POST">
  <div class="form-horizontal">
    <rhn:csrf />
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="probeedit.jsp.probecommand" />
      </label>
      <div class="col-lg-2 text">
        ${probe.command.description}
      </div>
    </div>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="probeedit.jsp.satclusterdesc" />
      </label>
      <div class="col-lg-2 text">
        ${probe.satCluster.description}
     </div>
    </div>
    <c:if test='${not empty probe.command.systemRequirements}'>
      <div class="form-group">
        <label class="col-lg-3 control-label">
          <bean:message key="probeedit.jsp.commandrequirements" />
        </label>
        <div class="col-lg-2 text">
          <bean:message key="${probe.command.systemRequirements}"/>
        </div>
      </div>
    </c:if>
    <c:if test='${not empty probe.command.versionSupport}'>
      <div class="form-group">
        <label class="col-lg-3 control-label">
          <bean:message key="probeedit.jsp.versionsupport" />
        </label>
        <div class="col-lg-2 text">
          ${probe.command.versionSupport}
        </div>
      </div>
    </c:if>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="probeedit.jsp.description" />
      </label>
      <div class="col-lg-2 text">
        <html:text property="description" maxlength="100" size="50" styleId="description"/>
      </div>
    </div>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="probeedit.jsp.notification" />
      </label>
      <div class="col-lg-2 text">
        <html:checkbox onclick="refreshNotifFields()" property="notification" styleId="notification"/>
      </div>
    </div>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="probeedit.jsp.notifmin" />
      </label>
      <div class="col-lg-2 text">
        <html:select property="notification_interval_min"
          disabled="${not probeEditForm.map.notification}" styleId="notifmin">
          <html:options collection="intervals"
            property="value"
            labelProperty="label" />
        </html:select>
      </div>
    </div>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="probeedit.jsp.notifmethod" />
      </label>
      <div class="col-lg-2 text">
        <html:select property="contact_group_id"
          disabled="${not probeEditForm.map.notification}" styleId="notifmethod">
          <html:options collection="contactGroups"
            property="value"
            labelProperty="label" />
        </html:select>
      </div>
    </div>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="probeedit.jsp.checkinterval" />
      </label>
      <div class="col-lg-2 text">
        <html:select property="check_interval_min" styleId="checkinterval">
          <html:options collection="intervals"
            property="value"
            labelProperty="label" />
        </html:select>
      </div>
    </div>

    <%@ include file="/WEB-INF/pages/common/fragments/probes/render-param-value-list.jspf" %>

    <html:submit styleClass="btn btn-success pull-right"><bean:message key="probedit.jsp.updateprobe" /></html:submit>
    <html:hidden property="sid" value="${param.sid}"/>
    <html:hidden property="probe_id" value="${probe.id}"/>
    <html:hidden property="submitted" value="true"/>
  </div>
</html:form>

</body>
</html>
