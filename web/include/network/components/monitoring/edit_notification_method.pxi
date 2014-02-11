<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
<pxt-use class="Grail::Frame" />
<pxt-use class="Sniglets::HTML" />
<pxt-use class="Sniglets::Users" />
<pxt-use class="Sniglets::ContactMethod" />

<h2>Notification Method Details</h2>

<pxt-formvar>

<div class="toolbar"><rhn-deletion-link url="delete_confirm.pxt?cmid={formvar:cmid}" type="method" /></div>
<div class="page-summary">
  <p>Edit this notification method using the form provided.</p>
</div>

<pxt-include-late file="/network/components/message_queues/local.pxi" />

    <pxt-form method="post">

<rhn-contact-method-edit-form>

      <table class="details">
        <tr>
          <th>Method Name:</th>
          <td><input type="text" size="30" name="method_name" value="{method_name}" maxlength="20" /></td>
        </tr>
        <tr>
          <th>Email:</th>
          <td><input type="text" size="30" name="method_email" value="{method_email}" maxlength="50" /></td>
        </tr>
        <tr>
          <th>Message Format:</th>
          <td>
	    <rhn-checkable type="checkbox" name="use_pager_type" value="1" checked="{use_pager_type}" />Short (Pager-Style) Messages
          </td>
        </tr>
      </table>

      <div align="right">
        <hr />
        <input type="hidden" name="pxt:trap" value="rhn:contact-method-edit-cb" />
        <input type="hidden" name="redirect_to" value="index.pxt?uid={uid}" />
        <input class="btn btn-default" type="submit" name="update_method" value="Update Method" />
        <pxt-hidden name="uid" />
        <pxt-hidden name="cmid" />
      </div>

</rhn-contact-method-edit-form>

    </pxt-form>
</pxt-formvar>

</pxt-passthrough>
