<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>

<head>

<meta http-equiv="Pragma" content="no-cache" />


<script language="javascript">
function setStep(stepName) {
	var field = document.getElementById("wizard-step");
	field.value = stepName;
}
function setContinue() {
        var field = document.getElementById("destroyDisks");
        field.value = "true";
}
</script>
</head>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
<br />
<h2>
  <rhn:icon type="header-kickstart" title="<bean:message key='system.common.kickstartAlt' />" />
  <bean:message key="kickstart.schedule.heading1.jsp" />
</h2>

<c:set var="actionUrl" value="/systems/details/kickstart/ScheduleWizard.do" />
<c:set var="form" value="${kickstartScheduleWizardForm.map}" />
<c:set var="regularKS" value="true" />
<html:form method="POST" action="${actionUrl}">
    <rhn:csrf />
    <rhn:submitted />
    <!-- Store form variables obtained from previous page -->
    <%@ include file="/WEB-INF/pages/common/fragments/date-picker-hidden.jspf" %>
    <input type="hidden" name="scheduleAsap" value="${form.scheduleAsap}" />
    <input type="hidden" name="cobbler_id" value="${form.cobbler_id}" />
    <input type="hidden" name="sid" value="${form.sid}" />
    <input type="hidden" name="guestName" value="${form.guestName}" />
    <input type="hidden" name="proxyHost" value="${form.proxyHost}" />
    <input type="hidden" name="targetProfileType" value="${form.targetProfileType}" />
    <input type="hidden" name="targetProfile" value="${form.targetProfile}" />
    <input type="hidden" name="targetServerProfile" value="${form.targetServerProfile}" />

    <input type="hidden" name="postKernelParamsType" value="${form.postKernelParamsType}" />
    <input type="hidden" name="postKernelParams" value="${form.postKernelParams}" />
    <input type="hidden" name="kernelParamsType" value="${form.kernelParamsType}" />
    <input type="hidden" name="kernelParams" value="${form.kernelParams}" />

    <input type="hidden" name="networkType" value="${form.networkType}" />
    <input type="hidden" name="networkInterface" value="${form.networkInterface}" />
    <input type="hidden" name="bondType" value="${form.bondType}" />
    <input type="hidden" name="bondInterface" value="${form.bondInterface}" />
    <input type="hidden" name="bondOptions" value="${form.bondOptions}" />
    <input type="hidden" name="hiddenBondSlaveInterfaces" value="${rhn:arrayToString(form.bondSlaveInterfaces)}" />
    <input type="hidden" name="bondStatic" value="${form.bondStatic}" />
    <input type="hidden" name="bondAddress" value="${form.bondAddress}" />
    <input type="hidden" name="bondNetmask" value="${form.bondNetmask}" />
    <input type="hidden" name="bondGateway" value="${form.bondGateway}" />

    <!-- Store useful id fields -->
    <input type="hidden" name="wizardStep" value="${form.wizardStep}" id="wizard-step" />

    <c:if test="${empty regularKS}">
        <!-- Store guest provisioning info  -->
	    <input type="hidden" name="memoryAllocation" value="${form.memoryAllocation}" />
	    <input type="hidden" name="virtualCpus" value="${form.virtualCpus}" />
	    <input type="hidden" name="localStorageGigabytes" value="${form.localStorageGigabytes}" />
	    <input type="hidden" name="diskPath" value="${form.diskPath}" />
        <input type="hidden" name="macAddress" value="${form.macAddress}" />
    </c:if>
    <input type="hidden" name="destroyDisks" value="${form.destoryDisks}" id="destroyDisks" />

    <p>
        <bean:message key="kickstarts.jsp.diskwarning" />
    </p>

    <input type="button" value="<bean:message key='sdc.channels.confirmNewBase.cancel' />" onclick="setStep('first');this.form.submit();" />
    <input type="button" value="<bean:message key='errata.publish.packagepush.continue' />" onclick="setContinue();this.form.submit();" />
</html:form>
</body>
</html>