<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<a id="profiles">&#160;</a>
<h2><bean:message key="ssm.misc.index.profileupdates.header"/></h2>
<div class="page-summary">
<p><bean:message key="ssm.misc.index.profileupdates.summary"/></p>
</div>
<ul>
  <li><a href="/rhn/systems/ssm/misc/HardwareRefresh.do"><bean:message key="ssm.misc.index.profileupdates.hardware"/></a></li>
  <li><a href="/rhn/systems/ssm/misc/SoftwareRefresh.do"><bean:message key="ssm.misc.index.profileupdates.software"/></a></li>
</ul>
<br />

<a id="migrate">&#160;</a>
<h2><bean:message key="ssm.misc.index.migrate.header"/></h2>

<div class="page-summary">
<p><bean:message key="ssm.misc.index.migrate.summary"/></p>

</div>

<ul>
  <li><a href="/rhn/systems/ssm/MigrateSystems.do"><bean:message key="ssm.misc.index.migrate.migrate"/></a></li>
</ul>

<br />

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

<a id="reboot">&#160;</a>
<h2><bean:message key="ssm.misc.index.reboot.header"/></h2>
<div class="page-summary">
<p><bean:message key="ssm.misc.index.reboot.summary"/></p>
</div>
<ul>
  <li><a href="/network/systems/ssm/misc/reboot_systems.pxt?pxt:trap=rhn:empty_set&amp;set_label=target_systems"><bean:message key="ssm.misc.index.reboot.header"/></a></li>
</ul>
<br />

<a id="delete">&#160;</a>
<h2><bean:message key="ssm.misc.index.lock.header"/></h2>

<div class="page-summary">
<p><bean:message key="ssm.misc.index.lock.summary"/></p>
</div>
<ul>
  <li><a href="/network/systems/ssm/misc/lock_systems_conf.pxt"><bean:message key="ssm.misc.index.lock.lock"/></a></li>
  <li><a href="/network/systems/ssm/misc/unlock_systems_conf.pxt"><bean:message key="ssm.misc.index.lock.unlock"/></a></li>
</ul>
<br />

<a id="delete">&#160;</a>
<h2><bean:message key="ssm.misc.index.delete.header"/></h2>
<div class="page-summary">
<p><bean:message key="ssm.misc.index.delete.summary"/></p>
</div>
<ul>
  <li><a href="/rhn/systems/ssm/DeleteConfirm.do"><bean:message key="ssm.misc.index.delete.delete"/></a></li>
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
        <th align="left">Preference</th>
        <th width="5%">Yes</th>
        <th width="5%">No</th>

        <th width="5%">No&#160;Change</th>
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

  <div align="right">
    <hr />

    <input type="submit" name="sscd_change_system_prefs" value="Change Preferences" />
    <input type="hidden" name="do_nothing_redir" value="landing.pxt" />
    <input type="hidden" name="pxt:trap" value="rhn:ssm_change_system_prefs_cb" />
  </div>

</form>



</body>
</html>
