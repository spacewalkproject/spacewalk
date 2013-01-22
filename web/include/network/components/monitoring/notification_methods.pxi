<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
<pxt-use class="Grail::Frame" />
<pxt-use class="Sniglets::HTML" />
<pxt-use class="Sniglets::Lists" />

<h2>Monitoring Notification Methods</h2>

<pxt-formvar>

<div class="toolbar"><rhn-creation-link url="create.pxt?uid={formvar:uid}" type="method" /></div>

<div class="page-summary">
  <p>A list of methods available for notification of monitoring events.</p>
</div>

<rhn-listview class="Sniglets::ListView::ContactMethodList" mode="users_contact_methods">
  <empty_list_message>No Notification Methods Available.</empty_list_message>

  <column name="Method Name" label="method_name" sort_by="1" width="50%" align="left">
    <url>edit.pxt?cmid={column:recid}</url>
  </column>

  <column name="Destination" label="method_target" sort_by="1" width="30%" align="left" />
</rhn-listview>

</pxt-formvar>

</pxt-passthrough>
