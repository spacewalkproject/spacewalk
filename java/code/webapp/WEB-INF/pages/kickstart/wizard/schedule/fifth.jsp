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
<h2>
  <rhn:icon type="header-kickstart" title="system.common.kickstartAlt" />
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
    <rhn:hidden name="scheduleAsap" value="${form.scheduleAsap}" />
    <rhn:hidden name="cobbler_id" value="${form.cobbler_id}" />
    <rhn:hidden name="sid" value="${form.sid}" />
    <rhn:hidden name="guestName" value="${form.guestName}" />
    <rhn:hidden name="proxyHost" value="${form.proxyHost}" />
    <rhn:hidden name="targetProfileType" value="${form.targetProfileType}" />
    <rhn:hidden name="targetProfile" value="${form.targetProfile}" />
    <rhn:hidden name="targetServerProfile" value="${form.targetServerProfile}" />

    <rhn:hidden name="postKernelParamsType" value="${form.postKernelParamsType}" />
    <rhn:hidden name="postKernelParams" value="${form.postKernelParams}" />
    <rhn:hidden name="kernelParamsType" value="${form.kernelParamsType}" />
    <rhn:hidden name="kernelParams" value="${form.kernelParams}" />

    <rhn:hidden name="networkType" value="${form.networkType}" />
    <rhn:hidden name="networkInterface" value="${form.networkInterface}" />
    <rhn:hidden name="bondType" value="${form.bondType}" />
    <rhn:hidden name="bondInterface" value="${form.bondInterface}" />
    <rhn:hidden name="bondOptions" value="${form.bondOptions}" />
    <rhn:hidden name="hiddenBondSlaveInterfaces" value="${rhn:arrayToString(form.bondSlaveInterfaces)}" />
    <rhn:hidden name="bondStatic" value="${form.bondStatic}" />
    <rhn:hidden name="bondAddress" value="${form.bondAddress}" />
    <rhn:hidden name="bondNetmask" value="${form.bondNetmask}" />
    <rhn:hidden name="bondGateway" value="${form.bondGateway}" />

    <!-- Store useful id fields -->
    <rhn:hidden name="wizardStep" value="${form.wizardStep}" id="wizard-step" />

    <c:if test="${empty regularKS}">
        <!-- Store guest provisioning info  -->
            <rhn:hidden name="memoryAllocation" value="${form.memoryAllocation}" />
            <rhn:hidden name="virtualCpus" value="${form.virtualCpus}" />
            <rhn:hidden name="localStorageGigabytes" value="${form.localStorageGigabytes}" />
            <rhn:hidden name="diskPath" value="${form.diskPath}" />
        <rhn:hidden name="macAddress" value="${form.macAddress}" />
    </c:if>
    <rhn:hidden name="destroyDisks" value="${form.destoryDisks}" id="destroyDisks" />

    <p>
        <bean:message key="kickstarts.jsp.diskwarning" />
    </p>

    <input type="button" class="btn btn-default" value="<bean:message key='sdc.channels.confirmNewBase.cancel' />" onclick="setStep('first');this.form.submit();" />
    <input type="button" class="btn btn-default" value="<bean:message key='errata.publish.packagepush.continue' />" onclick="setContinue();this.form.submit();" />
</html:form>
</body>
</html>
