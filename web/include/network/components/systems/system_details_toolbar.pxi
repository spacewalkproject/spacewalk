<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
<pxt-use class="Sniglets::HTML" />
<pxt-use class="Sniglets::Servers" />
<pxt-use class="Sniglets::Users" />
<pxt-formvar>
<!-- Regular system -->
<rhn-require acl="not system_is_virtual_host(); not system_is_virtual()">
  <rhn-toolbar base="h1" icon="header-system-physical"
      help-url="s1-sm-systems.jsp#s3-sm-system-details"
          deletion-url="/rhn/systems/details/DeleteConfirm.do?sid={formvar:sid}"
              deletion-type="system">
        <rhn-server-name />
  </rhn-toolbar>
</rhn-require>
<!-- virtual host -->
<rhn-require acl="system_is_virtual_host()">
  <rhn-toolbar base="h1" icon="header-system-virt-host"
      help-url="s1-sm-systems.jsp#s3-sm-system-details"
          deletion-url="/rhn/systems/details/DeleteConfirm.do?sid={formvar:sid}"
              deletion-type="system">
        <rhn-server-name />
  </rhn-toolbar>
</rhn-require>
<!-- virtual guest -->
<rhn-require acl="system_is_virtual()">
  <rhn-toolbar base="h1" icon="header-system-virt-guest"
      help-url="s1-sm-systems.jsp#s3-sm-system-details"
          deletion-url="/rhn/systems/details/DeleteConfirm.do?sid={formvar:sid}"
              deletion-type="system">
        <rhn-server-name />
  </rhn-toolbar>
</rhn-require>
</pxt-formvar>
</pxt-passthrough>
