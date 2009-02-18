<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

  <pxt-use class="Sniglets::Users" />
  <pxt-use class="Sniglets::HTML" />

<pxt-formvar>
    <rhn-toolbar base="h1" img="/img/rhn-icon-users.gif" help-url="s2-sm-user-active.jsp" deletion-url="/rhn/users/DeleteUser.do?uid={formvar:uid}" deletion-type="user" deletion-acl="user_role(org_admin)"><rhn-user-login /></rhn-toolbar>

</pxt-formvar>

  <rhn-navi-nav prefix="user_details" depth="0" file="/nav/user_detail.xml" style="contentnav" />

</pxt-passthrough>
