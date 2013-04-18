<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

  <pxt-use class="Sniglets::Lists" />

    <h2>Subscribers</h2>

    <div class="page-summary">
      <p>Selected users may subscribe systems to this channel.  Users with Admin Access (org admins or channel admins) may subscribe systems to any channel.</p>
    </div>

<pxt-include-late file="/network/components/message_queues/local.pxi" />

<rhn-listview class="Sniglets::ListView::UserList" mode="channel_subscribers">
  <formvars>
    <var name="cid" />
    <var name="set_label" type="literal">channel_subscription_perms</var>
  </formvars>

  <set name="selected users" label="channel_subscription_perms" />

  <column name="Login" label="user_login" align="left" />

  <column name="Full Name" label="full_name" />
  <column name="E-mail" label="email" />

  <column name="Status" label="disabled" />

  <action name="Update" label="update_channel_subscription_permissions" />

  <empty_list_message>No Users.</empty_list_message>
</rhn-listview>

</pxt-passthrough>
