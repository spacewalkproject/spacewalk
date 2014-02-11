<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<a id="profiles">&#160;</a>
<h2><bean:message key="ssm.misc.index.csi.header"/></h2>
<div class="page-summary">
<p><bean:message key="ssm.misc.index.csi.summary"/></p>
</div>
<ul>
  <li><a href="/network/systems/ssm/misc/choose_value_to_set.pxt"><bean:message key="ssm.misc.index.csi.set"/></a></li>
  <li><a href="/network/systems/ssm/misc/choose_value_to_remove.pxt"><bean:message key="ssm.misc.index.csi.remove"/></a></li>
</ul>
<br />

<a id="entitle">&#160;</a>
<h2><bean:message key="ssm.misc.index.entitle.header"/></h2>
<div class="page-summary">
  <p>
    <strong><bean:message key="ssm.misc.index.entitle.summary"/></strong>
  </p>
</div>

<a id="sysprefs">&#160;</a><h2><bean:message key="ssm.misc.index.syspref.header"/></h2>
<div class="page-summary">
<p><bean:message key="ssm.misc.index.syspref.summary"/></p>
</div>

<form action="/network/systems/ssm/misc/change_sys_pref_conf.pxt" method="post">

  <table width="96%" cellspacing="0" cellpadding="0" class="list" align="center">
    <thead>
      <tr>
        <th align="left"><bean:message key="ssm.misc.index.syspref.preference"/></th>
        <th width="5%"><bean:message key="yes"/></th>
        <th width="5%"><bean:message key="no"/></th>
        <th width="5%"><bean:message key="ssm.misc.index.syspref.nochange"/></th>
      </tr>
    </thead>

    <tr class="list-row-odd">
      <td><bean:message key="ssm.misc.index.syspref.notify"/></td>
      <td align="center"><input type="radio" name="receive_notifications" value="set" /></td>
      <td align="center"><input type="radio" name="receive_notifications" value="unset" /></td>

      <td align="center"><input type="radio" name="receive_notifications" value="do_nothing" checked="1" /></td>
    </tr>

    <tr class="list-row-even">
      <td><bean:message key="ssm.misc.index.syspref.dailysummary"/></td>
      <td align="center"><input type="radio" name="include_in_daily_summary" value="set" /></td>
      <td align="center"><input type="radio" name="include_in_daily_summary" value="unset" /></td>
      <td align="center"><input type="radio" name="include_in_daily_summary" value="do_nothing" checked="1" /></td>
    </tr>

    <tr class="list-row-odd">
      <td><bean:message key="ssm.misc.index.syspref.update"/></td>
      <td align="center"><input type="radio" name="auto_update" value="set" /></td>
      <td align="center"><input type="radio" name="auto_update" value="unset" /></td>
      <td align="center"><input type="radio" name="auto_update" value="do_nothing" checked="1" /></td>
    </tr>

  </table>

  <div class="text-right">
    <hr />

    <input class="btn btn-default" type="submit" name="sscd_change_system_prefs" value="<bean:message key='ssm.misc.index.syspref.changepreferences'/>" />
    <input type="hidden" name="do_nothing_redir" value="landing.pxt" />
    <input type="hidden" name="pxt:trap" value="rhn:ssm_change_system_prefs_cb" />
  </div>

</form>



</body>
</html>
