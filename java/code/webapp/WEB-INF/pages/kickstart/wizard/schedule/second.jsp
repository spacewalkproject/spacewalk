<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:xhtml />
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
   form.submit();
}

function setStep(stepName) {
	var field = document.getElementById("wizard-step");
	field.value = stepName;
}

function toggle(id, state) {
   var ctl = document.getElementById(id);
   ctl.disabled = !state;
}

function setInitialState() {
	var syncExisting = document.getElementById("syncExisting");
	var syncPackage = document.getElementById("syncPackage");
	var syncSystem = document.getElementById("syncSystem");
	var syncNone = document.getElementById("syncNone");
    if(!syncExisting.checked && !syncPackage.checked && 
        !syncSystem.checked && !syncNone.checked) {
	    syncExisting.checked = true;
	    toggle("syncSystemSelect", false);
	    toggle("syncPackageSelect", false);
    }
    if (!syncSystem.checked) {
        toggle("syncSystemSelect", false);
    }
    if (!syncPackage.checked) {
        toggle("syncPackageSelect", false);
    }
}
</script>
</head>

<body onload="setInitialState();">

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<br />
<h2><img src="/img/icon_kickstart_session-medium.gif" /><bean:message key="kickstart.schedule.heading4.jsp" /></h2>

<html:form method="POST" action="/systems/details/kickstart/ScheduleWizard.do" styleId="wizard-form">
    <html:hidden property="wizardStep" value="third" styleId="wizard-step" />
    <html:hidden property="scheduleAsap" />
    <html:hidden property="date_year" />
    <html:hidden property="date_month" />
    <html:hidden property="date_day" />
    <html:hidden property="date_hour" />
    <html:hidden property="date_minute" />
    <html:hidden property="date_am_pm" />
    <html:hidden property="cobbler_id" />
    <html:hidden property="sid" />
    <html:hidden property="proxyHost" />

    <html:hidden property="wizardStep" value="third" styleId="wizard-step" />
    <html:hidden property="wizardStep" value="third" styleId="wizard-step" />
    <table class="details">        
      <tr>
        <th width="10%"><bean:message key="kickstartdetails.jsp.kernel_options" />:</th>
        <td>
        	<c:set var="profile_url"><a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${requestScope.profile.id}">${requestScope.profile.label}</a></c:set>
        	<c:choose>
        		<c:when test = "${not requestScope.distro.rhnTree}">
        			<c:set var="distro_url"><a href="/rhn/kickstart/TreeEdit.do?kstid=${requestScope.distro.id}">${requestScope.distro.label}</a></c:set>
        		</c:when>
        		<c:otherwise>
        			<c:set var="distro_url">${requestScope.distro.label}</c:set>
        		</c:otherwise>
        	</c:choose>
        	
		  <html:radio value="distro" property="kernelParamsType" onclick="form.kernelParamsId.disabled = true;">
              <bean:message key="kickstart.schedule.kernel.options.distro" arg0="${distro_url}"/>
          </html:radio>:<br/>
          <c:choose> <c:when test = "${not empty requestScope.distro_kernel_params}"> ${requestScope.distro_kernel_params}</c:when>
          			<c:otherwise>(<bean:message key="none specified"/>)</c:otherwise>
          </c:choose>
        
        <br /><br />
		  <html:radio value="profile" property="kernelParamsType" onclick="form.kernelParamsId.disabled = true;">
              <bean:message key="kickstart.schedule.kernel.options.profile" arg0="${profile_url}"/>
		 </html:radio>:<br/>
          <c:choose> <c:when test = "${not empty requestScope.profile_kernel_params}"> ${requestScope.profile_kernel_params}</c:when>
          			<c:otherwise>(<bean:message key="none specified"/>)</c:otherwise>
          </c:choose>
          <br /><br />
          
		  <html:radio value="custom" property="kernelParamsType" onclick="form.kernelParamsId.disabled = false;">
              <strong><bean:message key="Custom" /></strong>
          </html:radio>: &nbsp;&nbsp;<html:text styleId = "kernelParamsId" property="kernelParams" onkeydown="return blockEnter(event)" disabled= "${kickstartScheduleWizardForm.map.kernelParamsType ne &quot;custom&quot;}" /><br /><br />
          <rhn:tooltip><bean:message key="kickstart.schedule.kernel.options.custom.tip" arg0="${rhn:localize('Custom')}"/></rhn:tooltip>                  
        </td>
      </tr>
      <tr>
        <th width="10%"><bean:message key="kickstartdetails.jsp.post_kernel_options" />:</th>
        <td>
		  <html:radio value="distro" property="postKernelParamsType" onclick="form.postKernelParamsId.disabled = true;">
				<bean:message key="kickstart.schedule.kernel.options.distro" arg0="${distro_url}"/>
          </html:radio>:<br/>
          <c:choose> <c:when test = "${not empty requestScope.distro_post_kernel_params}"> ${requestScope.distro_post_kernel_params}</c:when>
          			<c:otherwise>(<bean:message key="none specified"/>)</c:otherwise>
          </c:choose><br /><br />
        
		  <html:radio value="profile" property="postKernelParamsType" onclick="form.postKernelParamsId.disabled = true;">
              <bean:message key="kickstart.schedule.kernel.options.profile" arg0="${profile_url}"/>
		 </html:radio>:<br/>
          <c:choose> <c:when test = "${not empty requestScope.profile_post_kernel_params}"> ${requestScope.profile_post_kernel_params}</c:when>
          			<c:otherwise>(<bean:message key="none specified"/>)</c:otherwise>
          </c:choose><br /><br />
          
		  <html:radio value="custom" property="postKernelParamsType" onclick="form.postKernelParamsId.disabled = false;">
              <strong><bean:message key="Custom" /></strong>
          </html:radio>: &nbsp;&nbsp;<html:text styleId = "postKernelParamsId" 
          		property="postKernelParams" 
          		onkeydown="return blockEnter(event)" disabled= "${kickstartScheduleWizardForm.map.postKernelParamsType ne &quot;custom&quot;}"/><br /><br />                  
           <rhn:tooltip><bean:message key="kickstart.schedule.kernel.options.custom.tip" arg0="${rhn:localize('Custom')}"/></rhn:tooltip>
        </td>
        
      </tr>      
      
      <tr>
        <th width="10%"><bean:message key="kickstart.schedule.sync.pkg.profile.jsp" />:</th>
        <td>
          <html:radio styleId="syncExisting" value="existing" property="targetProfileType"
          				 onclick="form.syncPackageSelect.disabled = true; form.syncSystemSelect.disabled = true;">
              <bean:message key="kickstart.schedule.sync.pkg.profile.option1.jsp" />
          </html:radio><br /><br />
              <html:radio styleId="syncPackage"
              	 onclick="form.syncPackageSelect.disabled = false; form.syncSystemSelect.disabled = true;" 
              	 value="package" property="targetProfileType" disabled="${syncPackageDisabled}">
              <bean:message key="kickstart.schedule.sync.pkg.profile.option2.jsp" />
            </html:radio>:&nbsp;&nbsp;
            <html:select styleId="syncPackageSelect" property="targetProfile">
              <html:optionsCollection property="syncPackages" 
                label="name" value="id"/>
            </html:select>
          <br /><br />
          <html:radio styleId="syncSystem" value="system" property="targetProfileType" 
          		onclick="form.syncPackageSelect.disabled = true; form.syncSystemSelect.disabled = false;" 
          		disabled="${syncSystemDisabled}">
                <bean:message key="kickstart.schedule.sync.pkg.profile.option3.jsp" />
            </html:radio>:&nbsp;&nbsp;
              <html:select styleId="syncSystemSelect" property="targetProfile">
                <html:optionsCollection property="syncSystems" 
                  label="name" value="id"/>
              </html:select>
            <br /><br />                    
          <html:radio styleId="syncNone" value="none" property="targetProfileType"
          	 onclick="form.syncPackageSelect.disabled = true; form.syncSystemSelect.disabled = true;">
          	 <bean:message key="kickstart.schedule.sync.pkg.profile.option4.jsp" /></html:radio><br />	          
        </td>
      </tr>
    </table>
    <hr>
	<table width="100%">
	  <tr>
	    <td align="right">
	      <input type="button" value="<bean:message key="kickstart.schedule.button3.jsp" />" onclick="setStep('first');moveNext();" />	    
          <input type="button" value="<bean:message key="kickstart.schedule.button2.jsp" />" onclick="setStep('third');moveNext();" />
	    </td>
	  </tr>    
</html:form>
</div>
</body>
</html>
