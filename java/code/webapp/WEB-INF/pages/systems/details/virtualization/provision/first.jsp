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

<html:errors />

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
        <!--Store form variables obtained from previous page -->
        <input type="hidden" name="targetProfileType" value="${form.targetProfileType}"/>
        <input type="hidden" name="targetProfile" value="${form.targetProfile}" />
        <input type="hidden" name="kernelParams" value="${form.kernelParams}" />
        <input type="hidden" name="memoryAllocation" value="${form.memoryAllocation}" />
        <input type="hidden" name="virtualCpus" value="${form.virtualCpus}" />
        <input type="hidden" name="localStorageMegabytes" value="${form.localStorageMegabytes}" />
        <input type="hidden" name="diskPath" value="${form.diskPath}" />
                
        <!-- Store useful id fields-->
        <input type="hidden" name="wizardStep" value="first" id="wizard-step" />    
        <input type="hidden" name="cobbler_id" value="${form.cobbler_id}" id="cobbler_id" />
        <input type="hidden" name="sid" value="${form.sid}" />

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

    <c:if test="${requestScope.hasProxies == 'true'}">    
    <h2><img src="/img/rhn-icon-proxy.gif"/><bean:message key="kickstart.schedule.heading.proxy.jsp"/></h2>
    <p>
    <bean:message key="kickstart.schedule.msg.proxy.jsp"/>
    </p>
    <p>
        <select name="proxyHost">
			<c:forEach var="proxy" items="${proxies}">
  			  <option <c:if test="${proxy.value eq proxyHost}">selected="selected"</c:if> value='${proxy.value}'>${proxy.label}</option>
			</c:forEach>
		</select>
    <br />
    <bean:message key="kickstart.schedule.tip.proxy.jsp"/>
    </p>
    </c:if>
    <c:if test="${requestScope.hasProfiles == 'true'}">    
      <h2><img src="/img/rhn-icon-schedule.gif" /><bean:message key="kickstart.schedule.heading3.jsp" /></h2>
          <table width="50%">
            <tr>
              <td><input type="radio" name="scheduleAsap" value="true" id="scheduleAsap"/><bean:message key="kickstart.schedule.heading3.option1.jsp" /></td>
            </tr>
            <tr>
              <td><input type="radio" name="scheduleAsap" value="false" id="scheduleDate" /><bean:message key="kickstart.schedule.heading3.option2.jsp" /><br /><br />
                  <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                    <jsp:param name="widget" value="date"/>
                  </jsp:include>
              </td>
            </tr>
          </table>
      <hr />
	  <table width="100%">
	    <tr>
	      <td align="right">
	        <input type="button" value="<bean:message key="kickstart.schedule.button1.jsp" />" onclick="setStep('second');this.form.submit();" />
            <input type="button" value="<bean:message key="kickstart.schedule.button2.jsp" />" onclick="setStep('third');this.form.submit();" />
	      </td>
	    </tr>
	  </table>
    </c:if>
    </div>
</rl:listset>
</div>

</body>
</html>

