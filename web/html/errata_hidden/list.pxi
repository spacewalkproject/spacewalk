<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

<pxt-use class="Sniglets::ListUtils" />
<pxt-use class="Sniglets::PublicErrata" />

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="99%" valign="top">
		<h1><img src="/img/rhn-icon-errata.gif"/>
                <pxt-formvar>
		<public-errata-product-name product="{formvar:product}"/>
		</pxt-formvar><public-errata-type /> Advisories
		</h1>
		</td>
		<td rowspan="2" valign="top" align="right">
			<table border="0" cellspacing="0" cellpadding="2">
				<tr>
					<td nowrap="1" align="right"><font style="color:#666666; font-family:helvetica; text-decoration:none; font-size:10pt;">Security</font></td>
					<td width="99%">
                  <img align="absmiddle" src="/img/wrh-security.gif" alt="Security Advisory" /></td>

				</tr>
				<tr>
					<td nowrap="1" align="right"><font style="color:#666666; font-family:helvetica; text-decoration:none; font-size:10pt;">Bug Fix</font></td>
					<td>
                  <img align="absmiddle" src="/img/wrh-bug.gif" alt="Bug Fix Advisory" /></td>
				</tr>
				<tr>
					<td nowrap="1" align="right"><font style="color:#666666; font-family:helvetica; text-decoration:none; font-size:10pt;">Enhancement</font></td>
					<td>
                  <img align="absmiddle" src="/img/wrh-product.gif" alt="Enhancement Advisory" /></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td><public-errata-filter /></td>
	</tr>
</table>

<br />


<table cellpadding="4" cellspacing="0" border="0" width="100%" class="list">
<public-errata-filter-type-url>
<thead>
<tr>
<pxt-formvar>
  <th align="center">Type</th>
  <th align="left">{severity}</th>
  <th align="left">{advisory}</th>
  <th align="left">{synopsis}</th>
  <th align="center">{date}</th>
</pxt-formvar>
</tr>
</thead>
</public-errata-filter-type-url>
<tbody>

<rhn-fix-list list_type="errata">
<empty_list_mesg>
	<tr class="list-row-odd">
		<td align="center" class="first-column last-column" colspan="4">No Errata</td>
	</tr>
</empty_list_mesg>
<public-errata-list>
	<tr class="{class}">
		<td valign="middle" align="center" class="first-column">{errata_icon}</td>
                <td valign="middle">{severity}</td>
		<td valign="middle">{errata_advisory_name}</td>
		<td valign="middle"><a href="/errata/{errata_advisory_html_version}">{errata_synopsis}</a></td>
		<td valign="middle" nowrap="1" class="last_column">{errata_update_date}</td>

	</tr>
</public-errata-list>
</rhn-fix-list>
</tbody>
</table>
</pxt-passthrough>
