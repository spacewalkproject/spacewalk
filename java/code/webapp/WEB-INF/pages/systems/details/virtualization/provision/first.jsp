<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<html:xhtml/>
<html>

  <head>
    <meta http-equiv="Pragma" content="no-cache"/>

    <script language="javascript">
function setStep(stepName) {
	var field = document.getElementById("wizard-step");
	field.value = stepName;
}
    </script>
  </head>

  <body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

   <br/>
    <div class="page-summary">
      <p>
        <bean:message key="virtualization.provision.first.jsp.summary1" arg0="${system.id}" arg1="${system.name}" />
      </p>
    </div>

     <h2><bean:message key="virtualization.provision.first.jsp.header1"/></h2>
<div>
<c:set var="form" value="${kickstartScheduleWizardForm.map}"/>
<rl:listset name="wizard-form">
	<rl:list width="100%" emptykey = "virtualization.provision.first.jsp.no.profiles" alphabarcolumn="label">
			<rl:decorator name = "PageSizeDecorator"/>
        	<rl:radiocolumn value="${current.cobblerId}" styleclass="first-column"/>
         	<rl:column headerkey="kickstartranges.jsp.profile" filterattr="label"  sortable="true" sortattr="label">
         		<a href="${current.cobblerUrl}">${fn:escapeXml(current.label)}</a>	
         	</rl:column>
         	<rl:column headerkey="kickstart.channel.label.jsp" bound="true" attr="channelLabel" sortable="true" sortattr="channelLabel"/>
         	<rl:column headerkey="kickstart.channel.virtCpu.jsp" bound="true" attr="virtCpus"/>
         	<rl:column headerkey="kickstart.channel.virtDisk.jsp" bound="true" attr="virtSpace"/>         	
         	<rl:column headerkey="kickstart.channel.virtMemory.jsp" bound="true" attr="virtMemory"/>
         	<rl:column headerkey="kickstart.channel.virtBridge.jsp" bound="true" attr="virtBridge" styleclass="last-column"/>
    </rl:list>
	
	<h2><bean:message key="virtualization.provision.first.jsp.header2" /></h2>
    <table class="details">
      <tr>
        <th><rhn:required-field key="virtualization.provision.first.jsp.guest_name.header"/></th>
        <td>
          <bean:message key="virtualization.provision.first.jsp.guest_name.message1"/>
          <br/>
          <input type="text" name="guestName" value="${form.guestName}" maxlength="256" size="20" />
          <br/>
          <bean:message key="virtualization.provision.first.jsp.guest_name.tip1" arg0="256"/>
        </td>
      </tr>
    </table>

    <h2><bean:message key="virtualization.provision.first.jsp.header3" /></h2>
    	<bean:message key="virtualization.provision.override.jsp.goto.advanced.options"
    								 arg0="${rhn:localize('kickstart.schedule.button1.jsp')}"/>
    	<br/><br/>
	<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/ks-wizard.jspf" %>
</rl:listset>
</div>

</body>
</html>
