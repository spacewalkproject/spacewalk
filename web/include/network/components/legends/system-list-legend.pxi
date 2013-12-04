<?xml version="1.0" encoding="UTF-8"?>

<pxt-passthrough>

<pxt-use class="Sniglets::Users" />

<div class="sideleg">
  <h4>System Legend</h4>
  <ul>
  <li><i class="fa fa-check-circle fa-1-5x text-success"></i>OK</li>
  <li><i class="fa fa-exclamation-circle fa-1-5x text-danger"></i>Critical</li>
  <li><i class="fa fa-exclamation-triangle fa-1-5x text-warning"></i></i>Warning</li>
  <li><i class="spacewalk-icon-unknown-system"></i>Unknown</li>
<rhn-require acl="org_entitlement(sw_mgr_enterprise)">
  <li><i class="fa fa-1-5x spacewalk-icon-locked-system"></i></i>Locked</li>
</rhn-require>
<rhn-require acl="org_entitlement(rhn_provisioning)">
  <li><i class="fa fa-rocket fa-1-5x"></i>Kickstarting</li>
</rhn-require>
  <li><i class="fa fa-clock-o fa-1-5x"></i>Pending Actions</li>
  <li><i class="fa fa-1-5x spacewalk-icon-Unentitled"></i>Unentitled</li>
<rhn-require acl="org_entitlement(rhn_monitor)">
  <li><i class="fa fa-1-5x spacewalk-icon-monitoring-status"></i>Monitoring Status</li>
</rhn-require>
  </ul>
</div>

</pxt-passthrough>
