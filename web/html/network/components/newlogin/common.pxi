<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

  <pxt-use class="Sniglets::HTML" />

  <h2>Login:</h2>
  <table class="details" align="center">
    <tr>
      <th>Desired Login<span class="required-form-field">*</span>:</th>
      <td>
        <input maxlength="45" name="login" value="{default:login}" type="text" size="15" />
      </td>
    </tr>
    <tr>
      <th>Desired Password<span class="required-form-field">*</span>:</th>
      <td>
        <input maxlength="32" name="password1" type="password" size="15" />
      </td>
    </tr>
    <tr>
      <th>Confirm Password<span class="required-form-field">*</span>:</th>
      <td>
        <input maxlength="32" name="password2" type="password" size="15" />
      </td>
    </tr>
  </table>
  <h2>Account Information:</h2>
  <table class="details" align="center">
    <tr>
      <th>First, Last Name<span class="required-form-field">*</span>:</th>
      <td>
        {title_selectbox}
        <input maxlength="40" vcard_name="vCard.FirstName" name="first_names" 
         value="{default:first_names}" type="TEXT" size="15" />
        <input maxlength="40" vcard_name="vCard.LastName" name="last_name" 
         value="{default:last_name}" type="TEXT" size="15" />
      </td>
    </tr>

    <tr>
       <th>Email<span class="required-form-field">*</span>:</th>
       <td>
           <input maxlength="100" vcard_name="vCard.Email" name="email" 
           value="{default:email}" type="TEXT" size="20" />
       </td>
    </tr>

<rhn-if-var formvar="corporate">
    <tr>
      <th>
        Company<span class="required-form-field">*</span>:
      </th>
      <td>
        <input maxlength="100" vcard_name="vCard.Company" name="company" value="{default:company}" type="TEXT" size="15" />
      </td>
    </tr>

    <tr>
      <th>Position:</th>
      <td>
        <input maxlength="100" vcard_name="vCard.JobTitle" name="title" 
         value="{default:title}" type="TEXT" size="15" />
      </td>
    </tr>
</rhn-if-var>

<rhn-require acl="not global_config(satellite)">
    <tr>
      <th>Street Address<span class="required-form-field">*</span>:</th>
      <td>
        <input maxlength="45" vcard_name="vCard.Home.StreetAddress" 
         name="address1" value="{default:address1}" type="TEXT"
         size="20" /><br />
        <input maxlength="45" 
         name="address2" value="{default:address2}" type="TEXT" size="20" />
      </td>
    </tr>

    <tr>
      <th>City<span class="required-form-field">*</span>:</th>
      <td>
        <input maxlength="45" vcard_name="vCard.Home.City" 
         name="city" value="{default:city}" type="TEXT" size="20" />
      </td>
    </tr>

    <tr>
      <th>State/Province<span class="required-form-field">*</span>:</th>
      <td>
        <input maxlength="45" vcard_name="vCard.Home.State" 
         name="state" value="{default:state}" type="TEXT" size="20" />
        <br />(required for US or Canada)
      </td>
    </tr>

    <tr>
      <th>Zip / Postal Code<span class="required-form-field">*</span>:</th>
      <td>
        <input maxlength="32" vcard_name="vCard.Zipcode" 
         name="zip" value="{default:zip}" type="TEXT" size="10" />
      </td>
    </tr>

    <tr>
      <th>Country<span class="required-form-field">*</span>:</th>
      <td>
        {country_selectbox}
      </td>
    </tr>

    <tr>
      <th>Phone<span class="required-form-field">*</span>:</th>
      <td>
        <input maxlength="20" vcard_name="vCard.Home.Phone" 
         name="phone" value="{default:phone}" type="TEXT" size="13" />
      </td>
    </tr>

    <tr>
      <th>Fax:</th>
      <td>
        <input maxlength="20" vcard_name="vCard.Home.Fax" 
         name="fax" value="{default:fax}" type="TEXT" size="13" />
      </td>
    </tr>
</rhn-require>
    <tr>
      <td style="border: 0; text-align: center" colspan="2"><span class="required-form-field">*</span> - Required Field</td>
    </tr>
</table>


<rhn-require acl="not global_config(satellite)">

<div align="right">
  <input name="continue" type="submit" value="Create Login" />
</div>

<h2>Contact Method</h2>
<div class="page-summary">
<p>I would like to receive information from Red Hat in the 
             following ways.
             (Please note: you may receive email from all of 
             Red Hat, not just regarding Red Hat Network.)</p>

<ol class="preference">
<li><input name="contact_email" type="checkbox" checked="1" /> Email</li>
<li><input name="contact_mail" type="checkbox" value="1" /> Regular Mail</li>
<li><input name="contact_call" type="checkbox" value="1" /> Phone</li>
<li><input name="contact_fax" type="checkbox" value="1" /> Fax</li>
</ol>


          <p>Red Hat has close relationships with many industry leaders.
             From time to time, our partners have special news and
             offerings to share with you.  If you'd like, we will pass
             this information on to you.</p>
          <p class="preference"><input name="contact_partner" type="checkbox" checked="1" /> Yes,
             I would like to hear about special offers from Red Hat's 
             partners.</p>

</div>
</rhn-require>

<div align="right">
<input name="continue" type="submit" value="Create Login" />
</div>
</pxt-passthrough>
