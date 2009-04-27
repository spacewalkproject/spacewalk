<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>
<pxt-use class="Sniglets::HTML" />
<pxt-use class="Sniglets::Servers" />
<pxt-use class="Sniglets::Users" />
<pxt-formvar>
<!-- Regular system -->
<rhn-require acl="not system_is_virtual_host(); not system_is_virtual()">
  <rhn-toolbar base="h1" img="/img/rhn-icon-system.gif" 
      alt="system" help-url="s1-sm-systems.jsp#s3-sm-system-details"
          deletion-url="/network/systems/details/delete_confirm.pxt?sid={formvar:sid}" 
              deletion-type="system">
        <rhn-server-name />
  </rhn-toolbar>
</rhn-require>
<!-- virtual host -->
<rhn-require acl="system_is_virtual_host()">
  <rhn-toolbar base="h1" img="/img/virt-host.png" 
      alt="system" help-url="s1-sm-systems.jsp#s3-sm-system-details"
          deletion-url="/network/systems/details/delete_confirm.pxt?sid={formvar:sid}" 
              deletion-type="system">
        <rhn-server-name />
  </rhn-toolbar>
</rhn-require>
<!-- virtual guest -->
<rhn-require acl="system_is_virtual()">
  <rhn-toolbar base="h1" img="/img/virt-guest.png" 
      alt="system" help-url="s1-sm-systems.jsp#s3-sm-system-details"
          deletion-url="/network/systems/details/delete_confirm.pxt?sid={formvar:sid}" 
              deletion-type="system">
        <rhn-server-name />
  </rhn-toolbar>
</rhn-require>
</pxt-formvar>
</pxt-passthrough>

