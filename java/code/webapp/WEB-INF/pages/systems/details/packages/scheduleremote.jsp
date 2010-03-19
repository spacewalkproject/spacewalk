<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="scheduleremote.jsp.scheduleremotecommand"/></h2>

<div class="page-summary">
   <p><bean:message key="scheduleremote.jsp.summary"/></p>
</div>

<html:form action="/systems/details/packages/ScheduleRemoteCommand">
  <table class="details" align="center">
    <tr>
      <th><bean:message key="scheduleremote.jsp.run"/></th>
      <td>
      <html:radio property="run_script" value="before" /><bean:message key="scheduleremote.jsp.beforepackageaction"/>
      <br/>
      <html:radio property="run_script" value="after" /><bean:message key="scheduleremote.jsp.afterpackageaction"/>
      </td>
    </tr>
    <tr>
      <th><bean:message key="scheduleremote.jsp.runasuser"/>:</th>
      <td><html:text property="username" maxlength="32" /></td>
    </tr>
    <tr>
      <th><bean:message key="scheduleremote.jsp.runasgroup" />:</th>
      <td><html:text property="group" maxlength="32" /></td>
    </tr>
    <tr>
      <th><bean:message key="scheduleremote.jsp.timeout" />:</th>
      <td><html:text property="timeout" maxlength="" size="6" /></td>
    </tr>
    <tr>
      <th><bean:message key="scheduleremote.jsp.script" />:</th>
      <td><html:textarea property="script" cols="80" rows="8" /></td>
    </tr>
    <tr>
      <th><bean:message key="scheduleremote.jsp.nosoonerthan" />:</th>
      <td>
      		${requestScope.scheduledDate}
      </td>
    </tr>
  </table>
  <html:hidden property="use_date" value="true" />

<html:hidden property="session_set_label" value="${param.session_set_label}" />
<html:hidden property="sid" value="${param.sid}" />
<html:hidden property="mode" value="${param.mode}" />
<html:hidden property="submitted" value="true" />
    <html:hidden property="use_date" />
    <html:hidden property="date_year" />
    <html:hidden property="date_month" />
    <html:hidden property="date_day" />
    <html:hidden property="date_hour" />
    <html:hidden property="date_minute" />
    <html:hidden property="date_am_pm" />

  <div align="right">
    <hr />
      <c:if test="${param.mode == 'remove'}">
	      <html:submit>
	          <bean:message key="scheduleremote.jsp.schedulepackageremoval"/>
	      </html:submit>
	  </c:if>
      <c:if test="${param.mode == 'upgrade'}">
	      <html:submit>
	          <bean:message key="scheduleremote.jsp.schedulepackageupgrade"/>
	      </html:submit>
	  </c:if>
      <c:if test="${param.mode == 'install'}">
	      <html:submit>
	          <bean:message key="scheduleremote.jsp.schedulepackageinstall"/>
	      </html:submit>
	  </c:if>
  </div>
</html:form>

</body>
</html>