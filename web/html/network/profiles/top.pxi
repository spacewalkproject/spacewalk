<pxt-formvar>
  <pxt-use class="Sniglets::Profiles" />
  <rhn-toolbar base="h1" deletion-url="delete.pxt?prid={formvar:prid}"
               deletion-acl="formvar_exists(prid)" deletion-type="stored profile">
    Stored Profile - <rhn-profile-name />
  </rhn-toolbar>
 
  <rhn-navi-nav prefix="profile" depth="0" file="profile-nav.xml" style="contentnav" />
</pxt-formvar>
