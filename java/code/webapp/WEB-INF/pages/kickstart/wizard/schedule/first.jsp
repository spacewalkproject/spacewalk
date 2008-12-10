<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html:xhtml />
<html>

<head>
<meta http-equiv="Pragma" content="no-cache" />

<script language="javascript">
//<!--
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

function setInitialState() {
  var scheduleAsap = document.getElementById("scheduleAsap");
  var scheduleDate = document.getElementById("scheduleDate");
  if(!scheduleAsap.checked && !scheduleDate.checked) {
      scheduleAsap.checked = true;
  }
  var cobbler_id = document.getElementById("cobbler_id");
  var wizform = document.getElementById("wizard-form");
  if(ksid.value == "") {  	
  	for(x = 0; x < wizform.length; x++) {
  	  if(wizform.elements[x].name == "items_selected") {
  	    wizform.elements[x].checked =  true;
  	    cobbler_id.value = wizform.elements[x].value;
  	    break;
      }
    }
  }
  else {
    for(x = 0; x < wizform.length; x++) {
  	  if(wizform.elements[x].name == "items_selected"
  	    && wizform.elements[x].value == ksid.value) {
  	    wizform.elements[x].checked =  true;  	    
  	    break;
      }
    }
  }
}
//-->
</script>
</head>

<body onload="setInitialState();">

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

    <html:form method="POST" action="/systems/details/kickstart/ScheduleWizard.do" styleId="wizard-form">
        <!--Store form variables obtained from previous page -->
        <html:hidden property="targetProfileType"/>
        <html:hidden property="targetProfile"/>
        <html:hidden property="kernelParams"/>
        
        <!-- Store useful id fields-->
        <html:hidden property="wizardStep" value="first" styleId="wizard-step" />    
        <html:hidden styleId="cobbler_id" property="cobbler_id" />
        <html:hidden property="sid" />
        <rhn:list pageList="${requestScope.pageList}" noDataText="kickstart.schedule.no.profiles.jsp">         
            <rhn:listdisplay renderDisabled="true" paging="true" filterBy="kickstartranges.jsp.profile">
                <rhn:set type="radio" value="${current.cobblerId}" />
                <rhn:column header="kickstartranges.jsp.profile">
                    ${fn:escapeXml(current.label)}
                </rhn:column>
                <rhn:column header="kickstart.channel.label.jsp">
                    ${fn:escapeXml(current.channelLabel)}
                </rhn:column>      
            </rhn:listdisplay>          
        </rhn:list>
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
          <html:select property="proxyHost">
              <html:optionsCollection name="proxies"/>
          </html:select>    
        <br />
        <bean:message key="kickstart.schedule.tip.proxy.jsp"/>
        </p>
        </c:if>
        <c:if test="${requestScope.hasProfiles == 'true'}">    
          <h2>
            <img src="/img/rhn-icon-schedule.gif"
                 alt="<bean:message key='system.common.scheduleAlt' />" />
            <bean:message key="kickstart.schedule.heading3.jsp" />
          </h2>
          <table width="50%">
            <tr>
              <td><html:radio styleId="scheduleAsap" property="scheduleAsap" value="true"><bean:message key="kickstart.schedule.heading3.option1.jsp" /></html:radio></td>
            </tr>
            <tr>
              <td><html:radio styleId="scheduleDate" property="scheduleAsap" value="false"><bean:message key="kickstart.schedule.heading3.option2.jsp" /></html:radio><br /><br />
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
                <input type="button" value="<bean:message key="kickstart.schedule.button1.jsp" />" onclick="setStep('second');moveNext();" />
                <input type="button" value="<bean:message key="kickstart.schedule.button2.jsp" />" onclick="setStep('third');moveNext();" />
              </td>
            </tr>
          </table>
        </c:if>
    </html:form>
    </div>

</c:if>

</body>
</html>
