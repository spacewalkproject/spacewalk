<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
<pxt-use class="Grail::Frame" />
<pxt-use class="Sniglets::HTML" />
<pxt-use class="Sniglets::Users" />
<pxt-use class="Sniglets::ContactMethod" />
<pxt-use class="Sniglets::Lists" />

<h2>Notification Method Deletion Confirmation</h2>

<pxt-include-late file="/network/components/message_queues/local.pxi" />

<rhn-if-method-dependencies value="true">
  <div class="page-summary">
    <p>The <strong><rhn-contact-method-name /></strong> Notification Method cannot be deleted due to the following dependencies:</p>
    <p>Please note that only systems which you have permission to manage will be linked to from this page.</p>
  </div>

  <rhn-listview class="Sniglets::ListView::ProbeList" mode="probes_for_contact_method">
    <column name="System" label="system_name" sort_by="1" align="left" width="35%">
      <url>/rhn/systems/details/Overview.do?sid={column:system_id}</url>
    </column>
    <column name="Probe" label="probe_description" width="30%" align="left">
      <url>/rhn/systems/details/probes/ProbeDetails.do?probe_id={column:probe_id}&amp;sid={column:system_id}</url>
    </column>
  </rhn-listview>
</rhn-if-method-dependencies>

<rhn-if-method-dependencies value="false">
  <div class="page-summary">
    <p>Delete Notification Method: <strong><rhn-contact-method-name /></strong></p>
  </div>
    <div align="right">
      <hr />
      <pxt-form method="post">
        <pxt-hidden name="cmid" />
        <input type="hidden" name="success_redirect" value="index.pxt?uid={formvar:uid}" />
        <input type="hidden" name="pxt:trap" value="rhn:contact-method-delete-cb" />
        <input class="btn btn-default" type="submit" name="delete_cm_confirm" value="Confirm Deletion" />
      </pxt-form>
    </div>
</rhn-if-method-dependencies>

</pxt-passthrough>
