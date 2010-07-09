<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:xhtml/>
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
  <html:form styleId="wizard-form" method="POST" action="/kickstart/CreateProfileWizard.do">
    <html:hidden property="wizardStep" styleId="wizard-curstep" />
    <html:hidden property="nextStep" styleId="wizard-nextstep"/>
    <html:hidden property="prevStep" styleId="wizard-prevstep" />
    <html:hidden property="kickstartLabel" />
    <html:hidden property="virtualizationTypeLabel" />
    <html:hidden property="kstreeId" />
    <html:hidden property="defaultDownload" />
    <html:hidden property="userDefinedDownload" />
    <h1><bean:message key="kickstart.jsp.create.wizard.step.three"/></h1>
    <table class="details" width="80%">
        <tr>
            <td colspan="2"><bean:message key="kickstart.jsp.create.wizard.third.heading1" /></td>
        </tr>
        <tr>
            <th width="14%"><rhn:required-field key="kickstart.root.password.jsp.label"/>:</th>
            <td><html:password property="rootPassword" /></td>
        </tr>
        <tr>
        	<th width="14%"><rhn:required-field key="kickstart.root.password.verify.jsp.label"/>:</th>
        	<td valign="bottom"><html:password property="rootPasswordConfirm" /></td>
        </tr>
        <tr>
            <td colspan="2" align="right">
                <input type="button" value="<bean:message key="wizard.jsp.previous.step" />" onclick="movePrevious();" />
                &nbsp;&nbsp;
                <input type="button" value="<bean:message key="wizard.jsp.finish.step" />" onclick="moveNext();" />
            </td>
        </tr>
    </table>
  </html:form>
  </html>
</div>
</body>
</html>

