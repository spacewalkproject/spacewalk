<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>
  <pxt-use class="Sniglets::HTML" />
  <pxt-use class="Sniglets::Users" />
  <pxt-use class="Sniglets::ServerGroup" />

<pxt-formvar>

  <rhn-toolbar base="h1"
               icon="header-system-groups"
               alt="system group"
               help-url="s1-sm-systems.jsp#s2-sm-system-group-list"
               misc-url="/network/systems/ssm/work_with_group.pxt?sgid={formvar:sgid}&amp;pxt_trap=rhn:work_with_group_cb"
               misc-alt="work with group"
               misc-icon="header-system-groups"
               misc-text="work with group"
               deletion-type="group"
               deletion-url="/rhn/groups/Delete.do?sgid={formvar:sgid}"
               deletion-acl="user_role(system_group_admin)">
	<rhn-server-group-name />
  </rhn-toolbar>

  <rhn-navi-nav prefix="system_group_details" depth="0" file="/nav/system_group_detail.xml" style="contentnav" />

</pxt-formvar>
</pxt-passthrough>
