<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>
<pxt-use class="Sniglets::Users" />

<div class="clearBox">
<div class="clearBoxInner">
<div class="clearBoxBody">

<pxt-form method="post">
<rhn-login-form>


<div class="formrow">
<pxt-include-late file="/network/components/message_queues/local.pxi" />

<span class="label"><pxt-config var="product_name"/> Login:</span> <span class="formfield"><input tabindex="2" type="text" name="username" size="10" maxlength="64" value="[formvar:username]" /></span>
</div>

<div class="formrow">
<span class="label">Password:</span> <span class="formfield"><input tabindex="2" type="password" name="password" size="10" maxlength="32" /></span>
</div>

<div class="formrow">
<span class="formfield"><input tabindex="2" type="submit" value=" &#160; Sign In&#160; " /></span>
[login_form_hidden]
</div>

</rhn-login-form>
</pxt-form>

</div>
</div>
</div>



</pxt-passthrough>
