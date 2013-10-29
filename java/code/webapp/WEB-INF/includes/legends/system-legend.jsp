<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div class="sideleg">
  <h4><bean:message key="system-legend.jsp.title"/></h4>
  <ul>
  <li><i class="fa fa-check-circle fa-1-5x text-success"></i><bean:message key="system-legend.jsp.fully"/></li>
  <li><i class="fa fa-exclamation-circle fa-1-5x text-danger"></i><bean:message key="system-legend.jsp.critical"/></li>
  <li><i class="fa fa-exclamation-triangle fa-1-5x text-warning"></i><bean:message key="system-legend.jsp.updates"/></li>
  <li><i class="fa fa-1-5x spacewalk-icon-unknown-system"></i><bean:message key="system-legend.jsp.notcheckingin"/></li>
  <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
    <li><i class="fa fa-1-5x spacewalk-icon-locked-system"></i><bean:message key="system-legend.jsp.locked"/></li>
  </rhn:require>
  <rhn:require acl="org_entitlement(rhn_provisioning)">
    <li><i class="fa fa-rocket fa-1-5x"></i><bean:message key="system-legend.jsp.kickstarting"/></li>
  </rhn:require>
  <li><i class="fa fa-clock-o fa-1-5x"></i><bean:message key="system-legend.jsp.pending"/></li>
  <li><i class="fa fa-1-5x spacewalk-icon-Unentitled"></i><bean:message key="system-legend.jsp.unentitled"/></li>
  <rhn:require acl="org_entitlement(rhn_monitor)">
  <li><i class="fa fa-1-5x spacewalk-icon-monitoring-status"></i><bean:message key="system-legend.jsp.monitoring"/></li>
  </rhn:require>
  <li><i class="fa fa-1-5x spacewalk-icon-virtual-host"></i><bean:message key="systemlist.jsp.virthost"/></li>
  <li><i class="fa fa-1-5x spacewalk-icon-virtual-guest"></i><bean:message key="systemlist.jsp.virtguest"/></li>
  <li><i class="fa fa-laptop fa-1-5x"></i><bean:message key="systemlist.jsp.nonvirt"/></li>
 </ul>
</div>
