<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

<pxt-use class="Sniglets::Users" />

<table cellpadding="0" cellspacing="0" border="0" style="table-layout:fixed">
	<col width="36" /><col width="100%" /><col width="14%" />
	<tr>
		<td width="36"><img src="/img/pixel.gif" width="36" height="1" alt="" border="0" /></td>
		<td width="100%" valign="top">
			<div class="pagetitle1"> </div>
		</td>
		<td width="14%">&#160;</td>
	</tr>
</table>
<br />

<!-- begin wrapper table -->
<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
                <td><img src="/img/pixel.gif" width="20" height="1" alt="" /></td>
                <td width="98%" valign="top">
                
                                <!-- begin page content -->
                                <img src="/img/rhr_login.gif" width="89" height="33" alt="Sign In" /><br />&#160;
                                <p>
                                
	                        <p class="palenote">Note: Our personalized web services require that your browser be enabled for JavaScript and cookies.</p> 
                                </p>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                                <td><span class="subhead1">Registered Users:</span>
						<p><!-- begin login pane -->


<pxt-form>
      <rhn-login-form method="POST">
<table width="150" border="0" cellspacing="0" cellpadding="3">

	<tr>
<pxt-include-late file="/network/components/message_queues/local.pxi" />	</tr>
	<tr>
		<td valign="middle">Username:</td>
               
                
		<td><input tabindex="2" type="text" name="username" size="20" maxlength="64" value="[formvar:username]"/></td>
        </tr>
        <tr>
                <td valign="middle">Password:&#160;</td>
               
                <td><input tabindex="2" type="password" name="password" size="20" maxlength="32" /></td>
        </tr>
        <tr>
        	<td colspan="2" valign="middle" nowrap="nowrap"><input
        	type="SUBMIT" name="SUBMIT" value="Sign In" /></td>
        </tr>
</table>
	[login_form_hidden]
	<pxt-hidden name="url_bounce" />
	</rhn-login-form>
</pxt-form>
<!-- end login pane --></p>
                                                &#160;
                                                

</td>
                                                
                                                <!-- spacer columm -->
                                                <td><img src="/img/pixel.gif" width="20" height="1" alt="" /></td>
                                                <!-- /spacer column -->

                                                <td valign="top" nowrap="nowrap"><span class="subhead1">Where can I use my Red Hat login?</span>
                                                <ul>
                                                        <li class="plushalfspace"><span class="smalltext">Convenient sitewide login for all of Red Hat</span></li>
                                                        <li class="plushalfspace"><span class="smalltext">Free trial version of Red Hat Network</span></li>
                                                        <li class="plushalfspace"><span class="smalltext">High speed software downloads</span></li>
                                                        <li class="plushalfspace"><span class="smalltext">Free tech support in our lively Community Forums</span></li>
                                                        <li class="plushalfspace"><span class="smalltext">Exclusive contests, discounts and promotions</span></li>
                                                </ul></td>
                                        </tr>
                                </table>
<p>&#160;<br /></p>
<!-- end content -->

         </td>
    <td><div class="rightmargin">&#160;</div></td>
  </tr>
</table>
<!-- end wrapper table -->
</pxt-passthrough>
