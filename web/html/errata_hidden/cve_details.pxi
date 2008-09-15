<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

<pxt-use class="Sniglets::PublicErrata" />

<!-- cve_details.pxi -->
<public-cve-heading>
<p>
<h1>{cve_name}</h1>
</p>
<p>
Updated packages to correct this issue are available along with our advisory
at the URLs below.  Users of the Red Hat Network can update their systems using
the 'up2date' tool.
</p>
</public-cve-heading>
<table border="0" cellspacing="0" cellpadding="0">
    <public-cve-details>
        <tr>
            <td>{errata_product}</td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td>{errata_advisory_id_url}</td>
        </tr>
    </public-cve-details>
</table>

</pxt-passthrough>
