<?xml version="1.0" encoding="UTF-8"?>

<pxt-passthrough>

<pxt-use class="Sniglets::Users" />

<div class="sideleg">
  <h4>System Legend</h4>
  <ul>
  <li><img src="/img/icon_up2date.gif" alt="" />OK</li>
  <li><img src="/img/icon_crit_update.gif" alt="" />Critical</li>
  <li><img src="/img/icon_reg_update.gif" alt="" />Warning</li>
  <li><i class="spacewalk-icon-unknown-system" />Unknown</li>
<rhn-require acl="org_entitlement(sw_mgr_enterprise)">
  <li><img src="/img/icon_locked.gif" alt="" />Locked</li>
</rhn-require>
<rhn-require acl="org_entitlement(rhn_provisioning)">
  <li><img src="/img/icon_kickstart_session.gif" alt="" />Kickstarting</li>
</rhn-require>
  <li><img src="/img/icon_pending.gif" alt="" />Pending Actions</li>
  <li><img src="/img/icon_unentitled.gif" alt="" />Unentitled</li>
<rhn-require acl="org_entitlement(rhn_monitor)">
  <li><img src="/img/icon_subicon_monitoring.gif" alt="" />Monitoring Status</li>
</rhn-require>
  </ul>
</div>

</pxt-passthrough>
