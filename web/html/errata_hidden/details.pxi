<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

<pxt-use class="Sniglets::PublicErrata" />

<public-errata-details>

<h1>{errata_icon} {errata_synopsis}</h1>

<table class="details">
	<tr>
		<th>Advisory:</th>
		<td>{errata_advisory_id}</td>
	</tr>
	<tr>	
		<th>Type:</th>
		<td>{errata_advisory_type}</td>
	</tr>
        <tr>
                <th>Severity:</th>
                <td>{severity}</td>
        </tr>
	<tr>	
		<th>Issued on:</th>
		<td>{errata_issue_date}</td>
	</tr>
	<tr>	
		<th>Last updated on:</th>
		<td>{errata_update_date}</td>
	</tr>
<public-errata-affected-products>
	<tr>
		<th valign="top">Affected Products:</th>
		<td>{affected_products}</td>
	</tr>
</public-errata-affected-products>
	<tr>
		<th valign="top">OVAL:</th>
		<td valign="top">{oval_link}</td>
	</tr>
<public-errata-cves>
	<tr>
		<th valign="top">CVEs (<a href="http://cve.mitre.org">cve.mitre.org</a>):</th>
		<td rowspan="2" valign="top">
<cve_entry_block><a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name={cve}">{cve}</a><br /></cve_entry_block>
		</td>
	</tr>
</public-errata-cves>
</table>

<br />

<h2>Details</h2>
<div class="page-summary">
<errata_topic><p>{errata_topic}</p></errata_topic>

<p>{errata_description}</p>
</div>


<br />

<h2>Solution</h2>
<div class="page-summary">{errata_solution}</div>
<br />

<h2>Updated packages</h2>

<table border="0" cellpadding="6" cellspacing="0">

<errata_updated_packages>
	<tr>
		<td colspan="2"><font color="#666666"><strong><a name="{product}">{product}</a></strong></font></td>
	</tr>
	<tr>
		<td colspan="2"><hr noshade="1" size="1" /></td>
	</tr>
	<_arch>
	<tr>
		<td colspan="2"><font color="#666666"><strong>{arch}:</strong></font></td>
	</tr>
	<_file_entry>
	<tr bgcolor="{color}">
		<td>{filename}</td>
		<td valign="top" align="right">&#160;&#160;&#160;&#160;<tt>{md5sum}</tt></td>
	</tr>
	</_file_entry>
	<tr>
		<td colspan="2">&#160;</td>
	</tr>
	</_arch>
</errata_updated_packages>

</table>


<errata_bugs_fixed>
<br />
<h2>Bugs fixed (see <A HREF="http://bugzilla.redhat.com/bugzilla">bugzilla</A> for more information)</h2>
<div class="page-summary">
<p>{errata_bugs_fixed}</p>
</div>
</errata_bugs_fixed>

<errata_references>
<br />
<h2>References</h2>
<div class="page-summary">
<public-errata-cves>
<cve_entry_block><a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name={cve}">http://cve.mitre.org/cgi-bin/cvename.cgi?name={cve}</a><br /></cve_entry_block>
</public-errata-cves>
{errata_references}
</div>
</errata_references>


<errata_keywords>
<br />
<h2>Keywords</h2>
<div class="page-summary">
{errata_keywords}
</div>
</errata_keywords>

</public-errata-details>

<br />

<hr border="1" />
These packages are GPG signed by Red Hat for security.  Our key and 
details on how to verify the signature are available from:<br />

<a href="https://www.redhat.com/security/team/key/#package">https://www.redhat.com/security/team/key/#package</a>

<p>The Red Hat security contact is <a href="mailto:secalert@redhat.com">secalert@redhat.com</a>.  More contact details at <a href="http://www.redhat.com/security/team/contact/">http://www.redhat.com/security/team/contact/</a></p>

</pxt-passthrough>
