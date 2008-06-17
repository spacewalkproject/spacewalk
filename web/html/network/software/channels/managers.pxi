<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>
  <pxt-use class="Sniglets::Lists" />

    <h2>Managers</h2>

    <div class="page-summary">
      <p>Selected users may manage this channel.  Users with Admin Access (org admins or channel admins) may manage any channel.</p>
    </div>

<pxt-include-late file="/network/components/message_queues/local.pxi" />

<rhn-listview class="Sniglets::ListView::UserList" mode="channel_managers" alphabar_column="user_login">
  <formvars>
    <var name="cid" />
    <var name="set_label" type="literal">channel_management_perms</var>
  </formvars>

  <set name="selected users" label="channel_management_perms" />

  <column name="Login" label="user_login" align="left" sort_by="1"/>

  <column name="Full Name" label="full_name" />
  <column name="E-mail" label="email" />

  <column name="Status" label="disabled" />

  <action name="Update" label="update_channel_management_permissions" />

  <empty_list_message>No Users.</empty_list_message>
</rhn-listview>

</pxt-passthrough>
