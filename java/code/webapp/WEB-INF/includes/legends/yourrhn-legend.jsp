<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div class="sideleg">
  <h4><bean:message key="yourrhn-legend.jsp.title" /></h4>
  <ul>
    <li><i class="fa fa-check-circle fa-1-5x text-success"></i><bean:message key="system-legend.jsp.fully" /></li>
    <li><i class="fa fa-exclamation-circle fa-1-5x text-danger"></i><bean:message key="system-legend.jsp.critical" /></li>
    <li><i class="fa fa-exclamation-triangle fa-1-5x text-warning"></i><bean:message key="system-legend.jsp.updates" /></li>
    <li><i class="fa fa-1-5x spacewalk-icon-unknown-system"></i><bean:message key="system-legend.jsp.notcheckingin" /></li>
    <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
      <li><i class="fa fa-1-5x spacewalk-icon-locked-system"></i><bean:message key="system-legend.jsp.locked" /></li>
    </rhn:require>
    <rhn:require acl="org_entitlement(rhn_provisioning)">
      <li><i class="fa fa-rocket fa-1-5x"></i><bean:message key="system-legend.jsp.kickstarting" /></li>
    </rhn:require>
    <li><i class="fa fa-clock-o fa-1-5x"></i><bean:message key="system-legend.jsp.pending" /></li>
    <li><i class="fa fa-times-circle-o fa-1-5x"></i><bean:message key="yourrhn-legend.jsp.failedactions" /></li>
    <li><i class="fa fa-check-circle-o fa-1-5x"></i><bean:message key="yourrhn-legend.jsp.completedactions" /></li>
    <rhn:require acl="show_monitoring();" mixins="com.redhat.rhn.common.security.acl.MonitoringAclHandler">
      <li><i class="fa fa-1-5x spacewalk-icon-monitoring-status"></i><bean:message key="system-legend.jsp.monitoring" /></li>
    </rhn:require>
    <li><i class="fa fa-shield fa-1-5x"></i><bean:message key="errata-legend.jsp.security" /></li>
    <li><i class="fa fa-bug fa-1-5x"></i><bean:message key="errata-legend.jsp.bugfix" /></li>
    <li><i class="fa fa-1-5x spacewalk-icon-enhancement"></i><bean:message key="errata-legend.jsp.enhancement" /></li>
  </ul>
</div>
