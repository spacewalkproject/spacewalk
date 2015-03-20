<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>

<head>
<meta http-equiv="Pragma" content="no-cache">
<script language="javascript">

function swapValues(fromCtlId, toCtlId) {
   var fromCtl = document.getElementById(fromCtlId);
   var toCtl = document.getElementById(toCtlId);
   toCtl.value = fromCtl.value;
}

function moveNext() {
   var form = $("form[name='kickstartCreateWizardForm']");
   swapValues("wizard-nextstep", "wizard-curstep");
   form.submit();
}

function movePrevious() {
   var form = $("form[name='kickstartCreateWizardForm']");
   swapValues("wizard-prevstep", "wizard-curstep");
   form.submit();
}


</script>
</head>

<body onload="setState();">

  <html:form method="POST" styleClass="form-horizontal" action="/kickstart/CreateProfileWizard.do">
    <rhn:csrf />
    <rhn:submitted />
    <html:hidden property="wizardStep" styleId="wizard-curstep" />
    <html:hidden property="nextStep" styleId="wizard-nextstep"/>
    <html:hidden property="prevStep" styleId="wizard-prevstep" />
    <html:hidden property="kickstartLabel" />
    <html:hidden property="virtualizationTypeLabel" />
    <html:hidden property="kstreeId" />
    <html:hidden property="defaultDownload" />
    <html:hidden property="userDefinedDownload" />
    <html:hidden property="kstreeUpdateType" />
    <rhn:toolbar base="h1" icon="header-kickstart"><bean:message key="kickstart.jsp.create.wizard.step.three"/></rhn:toolbar>
    <p><bean:message key="kickstart.jsp.create.wizard.third.heading1" /></p>
    <div class="panel panel-default">
      <div class="panel-body">
        <div class="form-group">
          <div class="col-sm-2">
            <rhn:required-field key="kickstart.root.password.jsp.label"/>:
          </div>
          <div class="col-sm-10">
            <html:password property="rootPassword" styleClass="form-control" />
          </div>
        </div>
        <div class="form-group">
          <div class="col-sm-2">
            <rhn:required-field key="kickstart.root.password.verify.jsp.label"/>:
          </div>
          <div class="col-sm-10">
            <html:password property="rootPasswordConfirm" styleClass="form-control" />
          </div>
        </div>
      </div>
      <div class="panel-footer text-center">
        <input type="button" value="<bean:message key='wizard.jsp.previous.step'/>" onclick="movePrevious();" class="btn btn-default" />
        &nbsp;&nbsp;
        <input type="submit" value="<bean:message key='wizard.jsp.finish.step'/>" onclick="moveNext();" class="btn btn-primary" />
      </div>
    </div>
  </html:form>
  </html>
</body>
</html>

