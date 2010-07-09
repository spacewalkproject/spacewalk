<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div class="sideleg">
  <h2><bean:message key="yourrhn-legend.jsp.title"/></h2>
  <ul>
  <li><img src="/img/icon_up2date.gif" alt="" /><bean:message key="system-legend.jsp.fully"/></li>
  <li><img src="/img/icon_crit_update.gif" alt="" /><bean:message key="system-legend.jsp.critical"/></li>
  <li><img src="/img/icon_reg_update.gif" alt="" /><bean:message key="system-legend.jsp.updates"/></li>
  <li><img src="/img/icon_checkin.gif" alt="" /><bean:message key="system-legend.jsp.notcheckingin"/></li>
  <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
    <li><img src="/img/icon_locked.gif" alt="" /><bean:message key="system-legend.jsp.locked"/></li>
  </rhn:require>
  <rhn:require acl="org_entitlement(rhn_provisioning)">
    <li><img src="/img/icon_kickstart_session.gif" alt="" /><bean:message key="system-legend.jsp.kickstarting"/></li>
  </rhn:require>
  <li><img src="/img/icon_pending.gif" alt="" /><bean:message key="system-legend.jsp.pending"/></li>
  <li><img src="/img/rhn-listicon-error.gif" alt="" /><bean:message key="yourrhn-legend.jsp.failedactions"/></li>
  <li><img src="/img/rhn-listicon-ok.gif" alt="" /><bean:message key="yourrhn-legend.jsp.completedactions"/></li>
<rhn:require	acl="show_monitoring();"
				mixins="com.redhat.rhn.common.security.acl.MonitoringAclHandler">
  <li><img src="/img/icon_subicon_monitoring.gif" alt="" /><bean:message key="system-legend.jsp.monitoring"/></li>
  </rhn:require>
  <li><img src="/img/wrh-security.gif" alt="" /><bean:message key="errata-legend.jsp.security"/></li>
  <li><img src="/img/wrh-bug.gif" alt="" /><bean:message key="errata-legend.jsp.bugfix"/></li>
  <li><img src="/img/wrh-product.gif" alt="" /><bean:message key="errata-legend.jsp.enhancement"/></li>
  </ul>
</div>
