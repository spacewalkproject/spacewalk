<?xml version="1.0" encoding="utf8"?>

<pxt-passthrough>

  <pxt-use class="Sniglets::Lists" />
  <pxt-use class="Sniglets::Users" />

<rhn-listview class="Sniglets::ListView::SystemGroupList" mode="visible_to_user">


  <column name="Updates" label="status_icon" align="center" width="5%">
    <url>/network/systems/groups/errata_list.pxt?sgid={column:id}</url>
  </column>
  <rhn-require acl="org_entitlement(rhn_monitor)">
    <column name="Health" label="monitoring_icon" align="center" width="1%" />
  </rhn-require>
  <column name="Group Name" label="group_name" width="50%" align="left">
    <url>/network/systems/groups/details.pxt?sgid={column:id}</url>
  </column>
  <column name="Systems" label="server_count" width="1%" align="center">
    <url>/network/systems/groups/system_list.pxt?sgid={column:id}</url>
  </column>
  <column name="Use in SSM" label="work_with_group" width="1%" align="center" />


</rhn-listview>

</pxt-passthrough>
