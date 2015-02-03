<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
<pxt-use class="Grail::Frame" />
<pxt-use class="Sniglets::HTML" />
<pxt-use class="Sniglets::Users" />
<pxt-use class="Sniglets::ContactMethod" />

<pxt-formvar>

<div class="spacewalk-toolbar-h2">
  <div class="spacewalk-toolbar">
    <rhn-deletion-link url="delete_confirm.pxt?cmid={formvar:cmid}" type="method" />
  </div>
  <h2>Notification Method Details</h2>
</div>
<div class="page-summary">
  <p>Edit this notification method using the form provided.</p>
</div>

<pxt-include-late file="/network/components/message_queues/local.pxi" />

    <pxt-form method="post" class="form-horizontal">

<rhn-contact-method-edit-form>

        <div class="form-group">
            <label class="col-sm-2 control-label">
                Method Name:
            </label>
            <div class="col-sm-6">
                <input type="text" size="30" name="method_name" value="{method_name}" maxlength="20" class="form-control">
            </div>
        </div>
        <div class="form-group">
            <label class="col-sm-2 control-label">
                Email:
            </label>
            <div class="col-sm-6">
                <input type="text" size="30" name="method_email" value="{method_email}" maxlength="50" class="form-control">
            </div>
        </div>
        <div class="form-group">
            <label class="col-sm-2 control-label">
                Message Format:
            </label>
            <div class="col-sm-6">
                <input type="checkbox" name="use_pager_type" value="1" checked="{use_pager_type}" />Short (Pager-Style) Messages
            </div>
        </div>

      <div class="pull-right">
        <hr />
        <input type="hidden" name="pxt:trap" value="rhn:contact-method-edit-cb" />
        <input type="hidden" name="redirect_to" value="index.pxt?uid={uid}" />
        <input class="btn btn-success" type="submit" name="update_method" value="Update Method" />
        <pxt-hidden name="uid" />
        <pxt-hidden name="cmid" />
      </div>

</rhn-contact-method-edit-form>

    </pxt-form>
</pxt-formvar>

</pxt-passthrough>
