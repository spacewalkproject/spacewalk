<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<html:xhtml />
<html>

<head>

<meta http-equiv="Pragma" content="no-cache" />

<script language="javascript">
//<!--
function setStep(stepName) {
	var field = document.getElementById("wizard-step");
	field.value = stepName;
}
//-->
</script>
</head>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<br />
<h2>
  <img src="/img/icon_kickstart_session-medium.gif"
       alt="<bean:message key='system.common.kickstartAlt' />" />
  <bean:message key="kickstart.schedule.heading1.jsp" />
</h2>

<c:if test="${requestScope.isVirtualGuest == 'true'}">    
    <div class="page-summary">
        <bean:message key="kickstart.schedule.cannot.provision.guest"/><p/>
        <c:if test="${requestScope.virtHostIsRegistered == 'true'}">    
            <bean:message key="kickstart.schedule.visit.host.virt.tab" arg0="${requestScope.hostSid}"/>
        </c:if>
    </div>
</c:if>

<c:if test="${requestScope.isVirtualGuest == 'false'}">    

    <div class="page-summary">
    <p>
        <bean:message key="kickstart.schedule.heading1.text.jsp" />
    </p>
    <h2><bean:message key="kickstart.schedule.heading2.jsp" /></h2>
    </div>

    <div class="page-summary">
    <p>
        <bean:message key="kickstart.schedule.heading2.text.jsp" />
    </p>

<c:set var="form" value="${kickstartScheduleWizardForm.map}"/>

<rl:listset name="wizard-form">
        <!--Store form variables obtained from previous page -->
        <input type="hidden" name="targetProfileType" value="${form.targetProfileType}"/>
        <input type="hidden" name="targetProfile" value="${form.targetProfile}" />
        
        <input type="hidden" name="postKernelParamsType" value="${form.postKernelParamsType}" />
        <input type="hidden" name="postKernelParams" value="${form.postKernelParams}" />
        <input type="hidden" name="kernelParamsType" value="${form.kernelParamsType}" />
        <input type="hidden" name="kernelParams" value="${form.kernelParams}" />
        
        <!-- Store useful id fields-->
        <input type="hidden" name="wizardStep" value="first" id="wizard-step" />    
        <input type="hidden" name="cobbler_id" value="${form.cobbler_id}" id="cobbler_id" />
        <input type="hidden" name="sid" value="${form.sid}" />
		<rl:list width="100%" emptykey = "kickstart.schedule.no.profiles.jsp" alphabarcolumn="label">
			<rl:decorator name = "PageSizeDecorator"/>        
        	<rl:radiocolumn value="${current.cobblerId}" styleclass="first-column"/>
         	<rl:column headerkey="kickstartranges.jsp.profile" filterattr="label" sortable="true" sortattr="label">
         		<a href="${current.cobblerUrl}">${fn:escapeXml(current.label)}</a>	
         	</rl:column>
         	
         	<rl:column headerkey="kickstart.distro.label.jsp"  sortable="true" sortattr="treeLabel">
         		<c:out value="${current.treeLabel}"/>	
         	</rl:column>
         	
         	<rl:column headerkey="kickstart.distro.sw_managed.jsp" sortable="true" sortattr="cobbler"
         		  styleclass="last-column">
                	<c:choose>
	                    <c:when test="${current.cobbler}">
	                    	<img src="/img/rhn-listicon-error.gif">
	                    </c:when>
						<c:otherwise>
							<img src="/img/rhn-listicon-checked.gif">
                    	</c:otherwise>
                    </c:choose>
         	</rl:column>
    	</rl:list>     	    
    	<rhn:tooltip>* - <bean:message key="kickstart.distro.cobbler-only.tooltip"/></rhn:tooltip>
        <c:if test="${requestScope.hasProxies == 'true'}">    
        <h2>
          <img src="/img/rhn-icon-proxy.gif"
               alt="<bean:message key='system.common.proxyAlt' />" />
          <bean:message key="kickstart.schedule.heading.proxy.jsp"/>
        </h2>
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
		 <%@ include file="/WEB-INF/pages/common/fragments/kickstart/schedule/schedule-options.jspf" %>
          
          <table width="100%">
            <tr>
              <td align="right">
	        <input type="button" value="<bean:message key="kickstart.schedule.button0.jsp" />" onclick="setStep('fourth');this.form.submit();" />
                <input type="button" value="<bean:message key="kickstart.schedule.button1.jsp" />" onclick="setStep('second');this.form.submit();" />
                <input type="button" value="<bean:message key="kickstart.schedule.button2.jsp" />" onclick="setStep('third');this.form.submit();" />
              </td>
            </tr>
          </table>
        </c:if>
	</rl:listset>
    </div>
</c:if>

</body>
</html>
