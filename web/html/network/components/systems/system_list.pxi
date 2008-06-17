<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

<pxt-use class="Sniglets::Lists" />
  <pxt-use class="Sniglets::Users" />

<rhn-listview class="Sniglets::ListView::SystemList" mode="visible_to_user" alphabar_column="name">

  <set name="users selected systems" label="system_list" />

  <column name="Updates" label="advisory_icon" align="center" width="5%" />

  <rhn-require acl="org_entitlement(rhn_monitor)">
    <column name="Health" label="monitoring_icon" align="center" width="5%" />
  </rhn-require>

  <column name="Errata" label="total_errata" align="center" width="5%">
    <url>/network/systems/details/errata_list.pxt?sid={column:id}</url>
  </column>
  <column name="Packages" label="outdated_packages" align="center" width="5%">
    <url>/network/systems/details/packages/upgrade.pxt?sid={column:id}</url>
  </column>
  <column name="System" label="server_name" sort_by="1" align="left" width="35%">
    <url>/rhn/systems/details/Overview.do?sid={column:id}</url>
  </column>
  <column name="Base Channel" label="channel_labels" align="left" />

  <column name="Entitlement" label="entitlement_level" width="5%"/>

</rhn-listview>

</pxt-passthrough>
