<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

            This history event was caused by a failed scheduled action.<br/>
          <p>If you have corrected the problem, you may reschedule the action below.</p>
          <pxt-form method="post">
<pxt-formvar>
            <pxt-hidden name="sid" />
            <input type="hidden" name="aid" value="{formvar:hid}" />
            <input type="hidden" name="success_redirect" value="/network/systems/details/history/pending.pxt" />
            <input type="hidden" name="pxt:trap" value="rhn:reschedule_action_cb" />
            <input type="submit" value="Reschedule" />
</pxt-formvar>
          </pxt-form>

</pxt-passthrough>