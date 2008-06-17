<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>
  <pxt-use class="Sniglets::Users" />
  <pxt-use class="Sniglets::HTML" />

<rhn-user-site-view>
        <div>{site_address} {site_city_state_zip}</div>
        <div>Phone: {site_phone}</div>
        <div>Fax: {site_fax}</div>
        <div>
          <a href="edit_address.pxt?type={site_type}&amp;uid={user_id}">Edit this address</a>
        </div>
</rhn-user-site-view>

</pxt-passthrough>

