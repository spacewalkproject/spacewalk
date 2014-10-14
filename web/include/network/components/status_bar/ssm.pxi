<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
<pxt-use class="Sniglets::Users" />
<pxt-use class="Sniglets::Lists" />
<pxt-use class="Sniglets::HTML" />

<rhn-require acl="user_authenticated(); org_entitlement(sw_mgr_enterprise)">
<ul class="nav navbar-nav navbar-primary navbar-right spacewalk-bar">
    <div class="btn-group">
        <button id="header_selcount" class="btn btn-default btn-link disabled">
            <rhn-set-totals set="system_list" noun="system"/>
            <!--span id="spacewalk-ssm-counter" class="badge">0</span>systems selected</span-->
        </button>

        <a href="/rhn/ssm/index.do">
            <button class="btn btn-primary" type="button">
                Manage
            </button>
        </a>
        <rhn-return-link default="/network">
            <a id="clear-btn" href="/rhn/systems/Overview.do?empty_set=true&amp;set_label=system_list&amp;return_url={return_url}">
                <button class="btn btn-danger" type="button">
                    Clear
                </button>
            </a>
        </rhn-return-link>
    </div>
</ul>
</rhn-require>
</pxt-passthrough>
