<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
<pxt-use class="Sniglets::Users" />
<pxt-use class="Sniglets::Lists" />
<pxt-use class="Sniglets::HTML" />

<div class="spacewalk-bar pull-right">
  <rhn-require acl="user_authenticated(); org_entitlement(sw_mgr_enterprise)">
    <span id="header_selcount">
      <rhn-set-totals set="system_list" noun="system"/>
      <!--span id="spacewalk-ssm-counter" class="badge">0</span>systems selected</span-->
    </span>

    <a class="button" href="/rhn/ssm/index.do">
      Manage
    </a>
    <rhn-return-link default="/network">
      <a id="clear-btn" class="button" href="/rhn/systems/Overview.do?empty_set=true&amp;set_label=system_list&amp;return_url={return_url}">Clear</a>
    </rhn-return-link>
  </rhn-require>
</div>
</pxt-passthrough>