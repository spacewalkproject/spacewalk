<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<html:html >

<head>
        <script language="javascript" type="text/javascript">

                function toggleIFText(ctl) {
                        var toDisable = null;
                        var toEnable = null;
                        if (ctl.id == "dhcpRadio") {
                                toDisable = document.getElementById("staticNetworkIf");
                                toEnable = document.getElementById("dhcpNetworkIf");
                        }
                        else {
                                toDisable = document.getElementById("dhcpNetworkIf");
                                toEnable = document.getElementById("staticNetworkIf");
                        }
                        toDisable.disabled = true;
                        toEnable.disabled = false;
                        toEnable.value = toDisable.value;
                        toDisable.value = "";
                }

        // Workaround for apparent Firefox bug. See Red Hat Bugzilla #459411.
        function init() {
            static = document.getElementById("staticNetworkIf");
            if (static.disabled == true) {
                static.value = "";
            }
        }

        </script>

<%
boolean dhcpIfDisabled = Boolean.valueOf(
        (String) request.getAttribute("dhcpIfDisabled")).booleanValue();
boolean staticIfDisabled = Boolean.valueOf(
        (String) request.getAttribute("staticIfDisabled")).booleanValue();
%>
<meta http-equiv="Pragma" content="no-cache" />
</head>

<body onload="init()">
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />



<div>
  <html:form method="post" action="/kickstart/SystemDetailsEdit.do" styleClass="form-horizontal">
    <rhn:csrf />
    <html:hidden property="ksid" />
    <html:hidden property="submitted" />
    <c:if test="${not ksdata.legacyKickstart}">
      <h2><bean:message key="kickstart.systemdetails.jsp.header2"/></h2>
      <div class="form-group">
        <label class="col-lg-3 control-label">
          <bean:message key="kickstart.selinux.jsp.label" />:
        </label>
        <div class="col-lg-6">
          <div class="radio">
            <label>
              <html:radio property="selinuxMode" value="enforcing" />
              <bean:message key="kickstart.selinux.enforce.policy.jsp.label" />
            </label>
          </div>
        </div>
      </div>
      <div class="form-group">
        <div class="col-lg-offset-3 col-lg-6">
          <div class="radio">
            <label>
              <html:radio property="selinuxMode" value="permissive" />
              <bean:message key="kickstart.selinux.warn.policy.jsp.label" />
            </label>
          </div>
        </div>
      </div>
      <div class="form-group">
        <div class="col-lg-offset-3 col-lg-6">
          <div class="radio">
            <label>
              <html:radio property="selinuxMode" value="disabled" />
              <bean:message key="kickstart.selinux.disable.policy.jsp.label" />
            </label>
          </div>
        </div>
      </div>
    </c:if>

    <h2><bean:message key="kickstart.systemdetails.jsp.header3"/></h2>
    <div class="form-group">
      <label class="col-lg-3 control-label">
      <bean:message key="kickstart.config.mgmt.jsp.label" />:       </label>
      </label>
      <div class="col-lg-6">
        <html:checkbox property="configManagement" />
        <span class="help-block"><bean:message key="kickstart.config.mgmt.tip.jsp.label" /></span>
      </div>
    </div>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="kickstart.remote.cmd.jsp.label" />:
      </label>
      <div class="col-lg-6">
        <html:checkbox property="remoteCommands"/>
        <span class="help-block"><bean:message key="kickstart.remote.cmd.tip.jsp.label" /></span>
      </div>
    </div>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="kickstart.registration.type.jsp.label" />:
      </label>
      <div class="col-lg-6">
        <bean:message key="kickstart.registration.type.jsp.message" />:
      </div>
    </div>
    <div class="form-group">
      <div class="col-lg-offset-3 col-lg-6">
        <div class="radio">
          <label>
            <html:radio property="registrationType" value="reactivation" />
            <bean:message key="kickstart.registration.type.reactivation.jsp.label" />
          </label>
        </div>
      </div>
    </div>
    <div class="form-group">
      <div class="col-lg-offset-3 col-lg-6">
        <div class="radio">
          <label>
            <html:radio property="registrationType" value="deletion" />
            <bean:message key="kickstart.registration.type.deletion.jsp.label" />
          </label>
        </div>
      </div>
    </div>
    <div class="form-group">
      <div class="col-lg-offset-3 col-lg-6">
        <div class="radio">
          <label>
            <html:radio property="registrationType" value="none" />
            <bean:message key="kickstart.registration.type.none.jsp.label" />
          </label>
        </div>
      </div>
    </div>

    <h2><bean:message key="kickstart.systemdetails.jsp.header4"/></h2>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="kickstart.root.password.jsp.label" />:
      </label>
      <div class="col-lg-6">
        <html:password property="rootPassword" maxlength="32" size="32" redisplay="false" styleClass="form-control"/>
      </div>
    </div>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="kickstart.root.password.verify.jsp.label" />:
      </label>
      <div class="col-lg-6">
        <html:password property="rootPasswordConfirm" maxlength="32" size="32" redisplay="false" styleClass="form-control"/>
      </div>
    </div>
    <div class="form-group">
      <div class="col-lg-offset-3 col-lg-6">
        <input type="submit" class="btn btn-success" value="<bean:message key='kickstart.systemdetails.edit.submit.jsp.label'/>" />
      </div>
    </div>
  </html:form>
</div>
</body>
</html:html>

