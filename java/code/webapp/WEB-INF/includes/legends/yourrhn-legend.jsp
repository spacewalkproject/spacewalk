<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div class="sideleg">
  <h4><bean:message key="yourrhn-legend.jsp.title" /></h4>
  <ul>
    <li><rhn:icon type="system-ok" /><bean:message key="system-legend.jsp.fully" /></li>
    <li><rhn:icon type="system-warn" /><bean:message key="system-legend.jsp.updates" /></li>
    <li><rhn:icon type="system-crit" /><bean:message key="system-legend.jsp.critical" /></li>
    <li><rhn:icon type="system-unknown" /><bean:message key="system-legend.jsp.notcheckingin" /></li>
    <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
      <li><rhn:icon type="system-locked" /><bean:message key="system-legend.jsp.locked" /></li>
    </rhn:require>
    <rhn:require acl="org_entitlement(rhn_provisioning)">
      <li><rhn:icon type="system-kickstarting" /><bean:message key="system-legend.jsp.kickstarting" /></li>
    </rhn:require>
    <li><rhn:icon type="action-pending" /><bean:message key="system-legend.jsp.pending" /></li>
    <li><rhn:icon type="action-failed" /><bean:message key="yourrhn-legend.jsp.failedactions" /></li>
    <li><rhn:icon type="action-ok" /><bean:message key="yourrhn-legend.jsp.completedactions" /></li>
    <rhn:require acl="show_monitoring();" mixins="com.redhat.rhn.common.security.acl.MonitoringAclHandler">
      <li><rhn:icon type="monitoring-status" /><bean:message key="system-legend.jsp.monitoring" /></li>
    </rhn:require>
    <li><rhn:icon type="errata-security" /><bean:message key="errata-legend.jsp.security" /></li>
    <li><rhn:icon type="errata-bugfix" /><bean:message key="errata-legend.jsp.bugfix" /></li>
    <li><rhn:icon type="errata-enhance" /><bean:message key="errata-legend.jsp.enhancement" /></li>
  </ul>
</div>
