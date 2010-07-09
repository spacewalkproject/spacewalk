<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:html xhtml="true">

<head>
<meta http-equiv="Pragma" content="no-cache"/>
<script language="javascript">

function setState() {
   var radio = document.getElementById("wizard-defaultdownloadon");
   if (radio.checked == true) {
      disableCtl('wizard-userdefdload');
   }
}

function disableCtl(ctlId) {
   var ctl = document.getElementById(ctlId);
   ctl.disabled = true;
}

function enableCtl(ctlId) {
   var ctl = document.getElementById(ctlId);
   ctl.disabled = false;
}

function swapValues(fromCtlId, toCtlId) {
   var fromCtl = document.getElementById(fromCtlId);
   var toCtl = document.getElementById(toCtlId);
   toCtl.value = fromCtl.value;
}

function moveNext() {
   var form = document.getElementById("wizard-form");
   swapValues("wizard-nextstep", "wizard-curstep");
   form.submit();
}

function movePrevious() {
   var form = document.getElementById("wizard-form");
   swapValues("wizard-prevstep", "wizard-curstep");
   form.submit();
}


</script>
</head>

<body onload="setState();">
<br />
<div>
  <html:form styleId="wizard-form" method="post" action="/kickstart/CreateProfileWizard.do">
    <html:hidden property="wizardStep" styleId="wizard-curstep" />
    <html:hidden property="nextStep" styleId="wizard-nextstep"/>
    <html:hidden property="prevStep" styleId="wizard-prevstep" />
    <html:hidden property="kickstartLabel" />
    <html:hidden property="virtualizationTypeLabel" />
    <html:hidden property="kstreeId" />
    <h1><bean:message key="kickstart.jsp.create.wizard.step.two"/></h1>
    <table class="details" width="80%">
        <tr>
            <td colspan="2"><bean:message key="kickstart.jsp.create.wizard.second.heading1" /></td>
        </tr>
        <tr>
            <th width="10%"><bean:message key="kickstart.jsp.create.wizard.default.download.location.label" />:</th>
            <td>
                <html:radio styleId="wizard-defaultdownloadon" property="defaultDownload" value="true" onclick="disableCtl('wizard-userdefdload');"><bean:write name="kickstartCreateWizardForm" property="defaultDownloadLocation" /></html:radio>
            </td>
       </tr>
       <tr>
            <th width="10%"><bean:message key="kickstart.jsp.create.wizard.custom.download.location.label" />:</th>
            <td>
                <html:radio styleId="wizard-defaultdownloadoff" property="defaultDownload" value="false" onclick="enableCtl('wizard-userdefdload');"><html:text property="userDefinedDownload" styleId="wizard-userdefdload" size="50" maxlength="512" /></html:radio>
            </td>
        </tr>
        <tr>
            <td colspan="2" align="right">
                <input type="button" value="<bean:message key="wizard.jsp.previous.step" />" onclick="movePrevious();" />
                &nbsp;&nbsp;
                <input type="button" value="<bean:message key="wizard.jsp.next.step" />" onclick="moveNext();" />
            </td>
        </tr>
    </table>
  </html:form>
</div>
</body>
</html:html>

