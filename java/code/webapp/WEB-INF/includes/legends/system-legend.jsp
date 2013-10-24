<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div class="sideleg">
  <h4><bean:message key="system-legend.jsp.title"/></h4>
  <ul>
  <li><i class="icon-ok-sign spacewalk-icon-green icon-1-5x"></i><bean:message key="system-legend.jsp.fully"/></li>
  <li><i class="icon-exclamation-sign spacewalk-icon-red icon-1-5x"></i><bean:message key="system-legend.jsp.critical"/></li>
  <li><i class="icon-warning-sign spacewalk-icon-yellow icon-1-5x"></i><bean:message key="system-legend.jsp.updates"/></li>
  <li><i class="spacewalk-icon-unknown-system icon-1-5x"></i><bean:message key="system-legend.jsp.notcheckingin"/></li>
  <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
    <li><i class="spacewalk-icon-locked-system icon-1-5x"></i><bean:message key="system-legend.jsp.locked"/></li>
  </rhn:require>
  <rhn:require acl="org_entitlement(rhn_provisioning)">
    <li><i class="icon-rocket icon-1-5x"></i><bean:message key="system-legend.jsp.kickstarting"/></li>
  </rhn:require>
  <li><i class="icon-time icon-1-5x"></i><bean:message key="system-legend.jsp.pending"/></li>
  <li><i class="spacewalk-icon-Unentitled icon-1-5x"></i><bean:message key="system-legend.jsp.unentitled"/></li>
  <rhn:require acl="org_entitlement(rhn_monitor)">
  <li><i class="spacewalk-icon-monitoring-status icon-1-5x"></i><bean:message key="system-legend.jsp.monitoring"/></li>
  </rhn:require>
  <li><i class="spacewalk-icon-virtual-host icon-1-5x"></i><bean:message key="systemlist.jsp.virthost"/></li>
  <li><i class="spacewalk-icon-virtual-guest icon-1-5x"></i><bean:message key="systemlist.jsp.virtguest"/></li>
  <li><i class="icon-laptop icon-1-5x"></i><bean:message key="systemlist.jsp.nonvirt"/></li>
 </ul>
</div>
