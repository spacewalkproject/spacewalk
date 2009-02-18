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

    <tr>
      <td style="border: 0; text-align: center" colspan="2"><span class="required-form-field">*</span> - Required Field</td>
    </tr>
</table>


<div align="right">
<input name="continue" type="submit" value="Create Login" />
</div>
</pxt-passthrough>
