<?xml version="1.0" encoding="UTF-8"?>

<pxt-passthrough>

<pxt-use class="Sniglets::Users" />
<pxt-use class="Sniglets::HTML" />

<div class="sideleg">
  <h4>System Legend</h4>
  <ul>
  <li><rhn-icon type="system-ok"/>OK</li>
  <li><rhn-icon type="system-crit"/>Critical</li>
  <li><rhn-icon type="system-warn"/>Warning</li>
  <li><rhn-icon type="system-unknown"/>Unknown</li>
<rhn-require acl="org_entitlement(sw_mgr_enterprise)">
  <li><rhn-icon type="system-locked"/>Locked</li>
</rhn-require>
<rhn-require acl="org_entitlement(rhn_provisioning)">
  <li><rhn-icon type="system-kickstarting"/>Kickstarting</li>
</rhn-require>
  <li><rhn-icon type="action-pending"/>Pending Actions</li>
  <li><rhn-icon type="system-unentitled"/>Unentitled</li>
<rhn-require acl="org_entitlement(rhn_monitor)">
  <li><rhn-icon type="monitoring-status"/>Monitoring Status</li>
</rhn-require>
  </ul>
</div>

</pxt-passthrough>
