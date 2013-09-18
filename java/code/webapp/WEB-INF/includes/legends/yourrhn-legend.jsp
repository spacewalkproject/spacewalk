<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div class="sideleg">
  <h4><bean:message key="yourrhn-legend.jsp.title" /></h4>
  <ul>
    <li><i class="icon-ok-sign"></i><bean:message key="system-legend.jsp.fully" /></li>
    <li><i class="icon-exclamation-sign"></i><bean:message key="system-legend.jsp.critical" /></li>
    <li><i class="icon-warning-sign"></i><bean:message key="system-legend.jsp.updates" /></li>
    <li><i class="spacewalk-icon-unknown-system"></i><bean:message key="system-legend.jsp.notcheckingin" /></li>
    <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
      <li><i class="spacewalk-icon-locked-system"></i><bean:message key="system-legend.jsp.locked" /></li>
    </rhn:require>
    <rhn:require acl="org_entitlement(rhn_provisioning)">
      <li><i class="spacewalk-icon-autoinstalling"></i><bean:message key="system-legend.jsp.kickstarting" /></li>
    </rhn:require>
    <li><i class="icon-time"></i><bean:message key="system-legend.jsp.pending" /></li>
    <li><i class="icon-remove-circle"></i><bean:message key="yourrhn-legend.jsp.failedactions" /></li>
    <li><i class="icon-ok-circle"></i><bean:message key="yourrhn-legend.jsp.completedactions" /></li>
    <rhn:require acl="show_monitoring();" mixins="com.redhat.rhn.common.security.acl.MonitoringAclHandler">
      <li><i class="spacewalk-icon-monitoring-status"></i><bean:message key="system-legend.jsp.monitoring" /></li>
    </rhn:require>
    <li><i class="icon-shield"></i><bean:message key="errata-legend.jsp.security" /></li>
    <li><i class="icon-bug"></i><bean:message key="errata-legend.jsp.bugfix" /></li>
    <li><i class="spacewalk-icon-enhancement"></i><bean:message key="errata-legend.jsp.enhancement" /></li>
  </ul>
</div>
