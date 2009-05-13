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
	var syncNone = document.getElementById("syncNone");
	var syncPackage = document.getElementById("syncPackage");
	var syncSystem = document.getElementById("syncSystem");
	if(!syncPackage.checked && !syncSystem.checked &&
	   !syncNone.checked) {
	    syncNone.checked = true;
        toggle("syncPackageSelect", false);
        toggle("syncSystemSelect", false);
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

    <html:errors />

    <html:messages id="message" message="true">
      <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
    </html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><img src="/img/icon_kickstart_session-medium.gif" /><bean:message key="kickstart.schedule.heading4.jsp" /></h2>

<html:form method="POST" action="/systems/details/virtualization/ProvisionVirtualizationWizard.do" styleId="wizard-form">
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
    <html:hidden property="guestName" />
    <html:hidden property="proxyHost" />
    <table class="details">        
      <tr>
        <th width="10%"><bean:message key="kickstart.schedule.kernel.params.jsp" />:</th>
        <td><html:text property="kernelParams" /></td>
      </tr>
      <tr>
        <th width="10%"><bean:message key="kickstart.schedule.sync.pkg.profile.jsp" />:</th>
        <td>
            <html:radio styleId="syncNone" value="none" property="targetProfileType" onclick="form.syncPackageSelect.disabled = true; form.syncSystemSelect.disabled = true;">
              <bean:message key="kickstart.schedule.sync.pkg.profile.option4.jsp" />
          </html:radio>
          <br /><br />                    
          <html:radio styleId="syncPackage" onclick="form.syncPackageSelect.disabled = false; form.syncSystemSelect.disabled = true;" value="package" property="targetProfileType" disabled="${syncPackageDisabled}">
              <bean:message key="kickstart.schedule.sync.pkg.profile.option2.jsp" />
          </html:radio>:&nbsp;&nbsp;
            <html:select styleId="syncPackageSelect" property="targetProfile">
              <html:optionsCollection property="syncPackages" 
                label="name" value="id"/>
            </html:select>
          <br /><br />
          <html:radio styleId="syncSystem" value="system" property="targetProfileType" onclick="form.syncPackageSelect.disabled = true; form.syncSystemSelect.disabled = false;" disabled="${syncSystemDisabled}">
              <bean:message key="kickstart.schedule.sync.pkg.profile.option3.jsp" />
          </html:radio>:&nbsp;&nbsp;
            <html:select styleId="syncSystemSelect" property="targetProfile">
              <html:optionsCollection property="syncSystems" 
                label="name" value="id"/>
            </html:select>
        </td>
      </tr>
    </table>
    
    <h2><bean:message key="virtualization.provision.first.jsp.header3" /></h2>
    	<bean:message key="virtualization.provision.override.jsp.message" />
    	<br/><br/>
    <table class="details">
      <tr>
        <th><bean:message key="virtualization.provision.first.jsp.memory_allocation.header"/></th>
        <td>
          <html:text property="memoryAllocation" maxlength="12" size="6"/>
          <bean:message key="virtualization.provision.first.jsp.memory_allocation.message2" arg0="${system.ramString}" arg1="${system.id}" arg2="${system.name}"/>
        </td>
      </tr>
      <tr>
        <th><bean:message key="virtualization.provision.first.jsp.virtual_cpus.header"/></th>
        <td>
          <html:text property="virtualCpus" maxlength="2" size="2"/>
          <br/>
          <bean:message key="virtualization.provision.first.jsp.virtual_cpus.tip1" arg0="32"/>
        </td>
      </tr>
      <tr>
        <th><bean:message key="virtualization.provision.first.jsp.storage"/></th>
        <td>
            <bean:message key="virtualization.provision.first.jsp.storage.local.message1"/>
            <html:text styleId="localStorageMegabytes" property="localStorageMegabytes" maxlength="20" size="6"/>
            <bean:message key="virtualization.provision.first.jsp.storage.local.gigabytes"/>
        </td>
      </tr>    
      <tr>
        <th><bean:message key="kickstartdetails.jsp.virt_bridge"/>:</th>
        <td>
            <html:text  property="virtBridge" maxlength="20" size="6"/>
            <bean:message key="virtualization.provision.first.jsp.virt_bridge.example"/>
            
        </td>
      </tr>        
      <tr>
        <th><bean:message key="kickstartdetails.jsp.virt_disk_path"/>:</th>
        <td>
            <html:text  property="diskPath" maxlength="64" size="20"/>
            <br/>
            <bean:message key="kickstartdetails.jsp.virt_disk_path.tip"/>
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
