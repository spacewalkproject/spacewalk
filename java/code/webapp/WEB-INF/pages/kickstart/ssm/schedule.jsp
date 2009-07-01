<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2><bean:message key="ssm.kickstartable-systems.jsp.title"/></h2>
  <div class="page-summary">
    <p>
    <bean:message key="ssm.kickstartable-systems.jsp.summary"/>
    </p>
  </div>

<br />
<h2>
  <img src="/img/icon_kickstart_session-medium.gif"
       alt="<bean:message key='system.common.kickstartAlt' />" />
  <bean:message key="kickstart.schedule.heading1.jsp" />
</h2>

    <div class="page-summary">
    <p>
        <bean:message key="ssm.kickstart.schedule.heading1.text.jsp" />
    </p>
    <h2><bean:message key="kickstart.schedule.heading2.jsp" /></h2>
    </div>

    <div class="page-summary">
    <p>
        <bean:message key="ssm.kickstart.schedule.heading2.text.jsp" />
    </p>
    </div>
<rl:listset name="form">
		<c:if test="${empty requestScope.isIP}">
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/profile-list.jspf" %>
		</c:if>
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/proxy-options.jspf" %>
		<br/>
		<h2>
          <bean:message key="ssm.kickstart.schedule.advanced.options"/>
        </h2>
		<table class="details">
      <tr>
        <th width="10%"><bean:message key="kickstartdetails.jsp.kernel_options" />:</th>
        <td>
        <input type="radio" name="kernelParamsType" value="distro" onclick="form.kernelParamsId.disabled = true;"
        		<c:if test="${empty kickstartScheduleWizardForm.map.kernelParamsType or kickstartScheduleWizardForm.map.kernelParamsType == 'distro'}">checked="checked"</c:if>
        		 />
              <bean:message key="kickstart.schedule.kernel.options.distro"/>
        <br /><br />
		  <input type="radio" name="kernelParamsType" value="profile" 
		  		<c:if test="${kickstartScheduleWizardForm.map.kernelParamsType == 'profile'}">checked="checked"</c:if>
		  			onclick="form.kernelParamsId.disabled = true;" />
              <bean:message key="kickstart.schedule.kernel.options.profile"/>
		 
          <br /><br />
          
		  <input type="radio" name="kernelParamsType" value="custom" 
		  			<c:if test="${kickstartScheduleWizardForm.map.kernelParamsType == 'custom'}">checked="checked"</c:if>
		  			onclick="form.kernelParamsId.disabled = false;" />
              <strong><bean:message key="Custom" /></strong>: &nbsp;&nbsp;
              <input type="text" name="kernelParams" value="${kickstartScheduleWizardForm.map.kernelParams}"
              <c:if test="${kickstartScheduleWizardForm.map.kernelParamsType ne 'custom'}">disabled= "true"</c:if>
               onkeydown="return blockEnter(event)" id="kernelParamsId" /><br /><br />
          <rhn:tooltip><bean:message key="kickstart.schedule.kernel.options.custom.tip" arg0="${rhn:localize('Custom')}"/></rhn:tooltip>                  
        </td>
      </tr>
      <tr>
        <th width="10%"><bean:message key="kickstartdetails.jsp.post_kernel_options" />:</th>
        <td>
		  <input type="radio" name="postKernelParamsType" value="distro" onclick="form.postKernelParamsId.disabled = true;" 
		  		<c:if test="${empty kickstartScheduleWizardForm.map.postKernelParamsType or kickstartScheduleWizardForm.map.postKernelParamsType == 'distro'}">checked="checked"</c:if>
		  	/>
				<bean:message key="kickstart.schedule.kernel.options.distro"/>
          <br /><br />
        
		  <input type="radio" name="postKernelParamsType" value="profile" onclick="form.postKernelParamsId.disabled = true;" 
		  			<c:if test="${kickstartScheduleWizardForm.map.postKernelParamsType == 'profile'}">checked="checked"</c:if>
		  			/>
              <bean:message key="kickstart.schedule.kernel.options.profile"/><br /><br />
          
		  <input type="radio" name="postKernelParamsType" value="custom" onclick="form.postKernelParamsId.disabled = false;" 
		  <c:if test="${kickstartScheduleWizardForm.map.postKernelParamsType == 'custom'}">checked="checked"</c:if>
		  />
              <strong><bean:message key="Custom" /></strong>: &nbsp;&nbsp;
              <input type="text" name="postKernelParams" value="${kickstartScheduleWizardForm.map.postKernelParams}"
              <c:if test="${kickstartScheduleWizardForm.map.postKernelParamsType ne 'custom'}">disabled= "true"</c:if>
               onkeydown="return blockEnter(event)" id="postKernelParamsId" />              
<br /><br />                  
           <rhn:tooltip><bean:message key="kickstart.schedule.kernel.options.custom.tip" arg0="${rhn:localize('Custom')}"/></rhn:tooltip>
        </td>
      </tr>		
		</table>
		
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/schedule-options.jspf" %>
<div align="right">
<hr />
<input type="submit" name="dispatch" value="${rhn:localize('kickstart.schedule.button2.jsp')}"/>
</div>
		
<rhn:submitted/>
</rl:listset>


</body>
</html>
