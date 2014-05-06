<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<%@ include file="/WEB-INF/includes/legends/system-history-type-legend.jsp" %>

<div class="sideleg">
  <h4><bean:message key="system-hisotry-legend.jsp.status.title" /></h4>
  <ul>
    <li><rhn:icon type="action-ok" /><bean:message key="system-history-legend.status.jsp.ok" /></li>
    <li><rhn:icon type="action-failed" /><bean:message key="system-history-legend.jsp.status.failed" /></li>
    <li><rhn:icon type="action-running" /><bean:message key="system-history-legend.jsp.status.running" /></li>
  </ul>
</div>
