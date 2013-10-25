<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
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

	    <c:if test="${empty requestScope.isIP}">
	        <bean:message key="ssm.kickstart.schedule.heading2.text.jsp" />
        </c:if>
	    <c:if test="${not empty requestScope.isIP}">
	        <bean:message key="ssm.kickstart.schedule.ip.heading2.text.jsp" />
        </c:if>

    </p>
    </div>




<c:set var="regularKS" value="true"/>
<c:set var="form" value="${kickstartScheduleWizardForm.map}"/>
<c:set var="noSystemProfile" value="true"/>
<c:set var="cobbler_only_tooltip" value="ssm.kickstart.distro.cobbler-only.tooltip"/>
<c:set var="proxy_summary_key" value="ssm.kickstart.schedule.proxy.jsp.summary"/>

<rl:listset name="form">
        <rhn:csrf />
		<c:if test="${empty requestScope.isIP}">
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/profile-list.jspf" %>
		</c:if>
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/proxy-options.jspf" %>		
		<br/>
		
<h2><img src="/img/icon_kickstart_session-medium.gif" /><bean:message key="kickstart.schedule.heading4.jsp" /></h2>
		<table class="table">
		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/network-options.jspf" %>
      <tr>
        <th width="10%"><bean:message key="kickstarttable.jsp.kernel_options" />:</th>
        <td>
        <input type="radio" name="kernelParamsType" value="distro" onclick="form.kernelParamsId.disabled = true;"
			<c:if test="${empty form.kernelParamsType or form.kernelParamsType == 'distro'}">checked="checked"</c:if>
			 />
              <bean:message key="kickstart.schedule.kernel.options.distro"/>
        <br /><br />
		  <input type="radio" name="kernelParamsType" value="profile"
				<c:if test="${form.kernelParamsType == 'profile'}">checked="checked"</c:if>
					onclick="form.kernelParamsId.disabled = true;" />
              <bean:message key="kickstart.schedule.kernel.options.profile"/>

          <br /><br />

		  <input type="radio" name="kernelParamsType" value="custom"
					<c:if test="${form.kernelParamsType == 'custom'}">checked="checked"</c:if>
					onclick="form.kernelParamsId.disabled = false;" />
              <strong><bean:message key="Custom" /></strong>: &nbsp;&nbsp;
              <input type="text" name="kernelParams" value="${form.kernelParams}"
              <c:if test="${form.kernelParamsType ne 'custom'}">disabled= "true"</c:if>
               onkeydown="return blockEnter(event)" id="kernelParamsId" /><br /><br />
          <rhn:tooltip><bean:message key="kickstart.schedule.kernel.options.custom.tip" arg0="${rhn:localize('Custom')}"/></rhn:tooltip>
        </td>
      </tr>
      <tr>
        <th width="10%"><bean:message key="kickstarttable.jsp.post_kernel_options" />:</th>
        <td>
		  <input type="radio" name="postKernelParamsType" value="distro" onclick="form.postKernelParamsId.disabled = true;"
				<c:if test="${empty form.postKernelParamsType or form.postKernelParamsType == 'distro'}">checked="checked"</c:if>
			/>
				<bean:message key="kickstart.schedule.kernel.options.distro"/>
          <br /><br />

		  <input type="radio" name="postKernelParamsType" value="profile" onclick="form.postKernelParamsId.disabled = true;"
					<c:if test="${form.postKernelParamsType == 'profile'}">checked="checked"</c:if>
					/>
              <bean:message key="kickstart.schedule.kernel.options.profile"/><br /><br />

		  <input type="radio" name="postKernelParamsType" value="custom" onclick="form.postKernelParamsId.disabled = false;"
		  <c:if test="${form.postKernelParamsType == 'custom'}">checked="checked"</c:if>
		  />
              <strong><bean:message key="Custom" /></strong>: &nbsp;&nbsp;
              <input type="text" name="postKernelParams" value="${form.postKernelParams}"
              <c:if test="${form.postKernelParamsType ne 'custom'}">disabled= "true"</c:if>
               onkeydown="return blockEnter(event)" id="postKernelParamsId" />
<br /><br />
           <rhn:tooltip><bean:message key="kickstart.schedule.kernel.options.custom.tip" arg0="${rhn:localize('Custom')}"/></rhn:tooltip>
        </td>
      </tr>

      <%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/profile-sync.jspf" %>
		</table>

		<%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/schedule-options.jspf" %>
	  <p>
	    <bean:message key="kickstarts.jsp.diskwarningssm" />
	  </p>
<div align="right">
<hr />
<input type="submit" name="dispatch" value="${rhn:localize('kickstart.schedule.button2.jsp')}"/>
</div>

<rhn:submitted/>
</rl:listset>


</body>
</html>
