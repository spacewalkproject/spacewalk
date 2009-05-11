<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>
  <pxt-use class="Sniglets::ActivationKeys" />

  <pxt-formvar>

<rhn-token-details>
    <rhn-toolbar base="h1" img="/img/rhn-icon-keyring.gif"
                 help-url="s1-sm-systems.jsp#s2-sm-systems-activation-keys" deletion-type="key"
                 deletion-url="/rhn/activationkeys/Delete.do?tid={formvar:tid}" deletion-acl="formvar_exists(tid)">
      {token:note}
    </rhn-toolbar>

    <rhn-navi-nav prefix="activation_key" depth="0" file="/nav/activation_key.xml" style="contentnav" />

</rhn-token-details>

  </pxt-formvar>
</pxt-passthrough>
