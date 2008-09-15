<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

  <pxt-use class="Sniglets::Errata" />
  <pxt-use class="Sniglets::Navi" />

<pxt-formvar>
  <rhn-toolbar base="h1" img="/img/rhn-icon-errata.gif" help-guide="channel-mgmt" help-url="s1-sm-errata.jsp" deletion-type="erratum" deletion-url="/network/errata/manage/delete_confirm.pxt?eid={formvar:eid}" deletion-acl="user_role(channel_admin); formvar_exists(eid)">
    Erratum: <rhn-errata-advisory />
  </rhn-toolbar>
</pxt-formvar>

    <rhn-navi-nav prefix="manage_errata" depth="0" file="/nav/manage_errata.xml" style="contentnav" />

</pxt-passthrough>
