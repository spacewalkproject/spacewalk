<?xml version="1.0" encoding="UTF-8"?>
<pxt-passthrough>

  <pxt-use class="Sniglets::Channel" />
  <pxt-use class="Sniglets::Navi" />

<rhn-channel-details>
  <rhn-toolbar base="h1" icon="header-channel" help-url="sect-Getting_Started_Guide-Channel_Management-Creating_and_Managing_Custom_Channels-Removing_Software_Packages.jsp" help-guide="getting-started" deletion-type="software channel" deletion-url="/rhn/channels/manage/Delete.do?cid={channel_id}" deletion-acl="user_role(channel_admin); formvar_exists(cid)">
    Software Channel: {channel_name}
  </rhn-toolbar>
</rhn-channel-details>

    <rhn-navi-nav prefix="manage_channel" depth="0" file="/nav/manage_channel.xml" style="contentnav" />

</pxt-passthrough>
