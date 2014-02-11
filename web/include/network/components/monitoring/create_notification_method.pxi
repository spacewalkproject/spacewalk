<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
<pxt-use class="Grail::Frame" />
<pxt-use class="Sniglets::HTML" />
<pxt-use class="Sniglets::Users" />
<pxt-use class="Sniglets::ContactMethod" />

<h2>Create Notification Method</h2>

<pxt-formvar>

<div class="page-summary">
  <p>Create a notification method using the form provided.</p>
</div>

<pxt-include-late file="/network/components/message_queues/local.pxi" />


    <pxt-form method="post">

      <table class="details">

        <tr>
          <th>Method Name:</th>
          <td><input type="text" size="30" name="method_name" value="" maxlength="20" /></td>
        </tr>
        <tr>
          <th>Email:</th>
          <td><input type="text" size="30" name="method_email" value="" maxlength="50" /></td>
        </tr>
        <tr>
          <th>Message Format:</th>
          <td>
	    <rhn-checkable type="checkbox" name="use_pager_type" value="1" checked="" />Short (Pager-Style) Messages
          </td>
        </tr>
      </table>

      <div align="right">
        <hr />
        <input type="hidden" name="pxt:trap" value="rhn:contact-method-create-cb" />
        <input type="hidden" name="redirect_to" value="index.pxt?uid={formvar:uid}" />
        <input class="btn btn-default" type="submit" name="create_method" value="Create Method" />
        <pxt-hidden name="uid" />
      </div>

    </pxt-form>
</pxt-formvar>

</pxt-passthrough>
