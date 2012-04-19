<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<h2><bean:message key="ssm.overview.header"/></h2>


<table class="ssm-overview" align="center">
<div class="page-summary">
  <p><bean:message key="ssm.overview.summary"/></p>
  <p><bean:message key="ssm.overview.summary2"/></p>
</div>
  <tr>
    <td><img src="/img/rhn-icon-system.gif" alt=<bean:message key="ssm.overview.systems" /></td>
    <th><b><bean:message key="ssm.overview.systems"/>:</b></th>
    <td><bean:message key="ssm.overview.systems.list"/></td>
  </tr>

  <tr>
    <td><img src="/img/rhn-icon-errata.gif" alt="Errata" /></td>
    <th><b><bean:message key="ssm.overview.errata"/></b></th>
    <td><bean:message key="ssm.overview.errata.schedule"/></td>
  </tr>

  <tr>
    <td><img src="/img/rhn-icon-packages.gif" alt="<bean:message key="ssm.overview.packages"/>" /></td>
    <th><b><bean:message key="ssm.overview.packages"/></b></th>
    <td><bean:message key="ssm.overview.packages.upgrade"/></td>
  </tr>

  <tr>
    <td><img src="/img/rhn-icon-system_group.gif" alt="<bean:message key="ssm.overview.groups"/>" /></td>
    <th><b><bean:message key="ssm.overview.groups"/></b></th>
    <td><bean:message key="ssm.overview.groups.create"/></td>
  </tr>

  <tr>
    <td><img src="/img/rhn-icon-channels.gif" alt="<bean:message key="ssm.overview.channels"/>" /></td>
    <th><b><bean:message key="ssm.overview.channels"/></b></th>
    <td>
      <p>
      <bean:message key="ssm.overview.channels.memberships"/><br />
      <bean:message key="ssm.overview.channels.subscriptions"/><br />
      <bean:message key="ssm.overview.channels.deploy"/><br />
      </p>
    </td>
  </tr>

  <tr>
    <td><img src="/img/rhn-kickstart_profile.gif" alt="<bean:message key="ssm.overview.provisioning"/>" /></td>
    <th><b><bean:message key="ssm.overview.provisioning"/></b></th>
    <td>
      <p>
      <bean:message key="ssm.overview.provisioning.kickstart"/><br />
      <bean:message key="ssm.overview.provisioning.rollback"/><br />
      <bean:message key="ssm.overview.provisioning.remotecommands"/><br />
      </p>
    </td>
  </tr>

  <tr>
    <td><img src="/img/rhn-icon-form.gif" alt="<bean:message key="ssm.overview.misc"/>" /></td>
    <th><b><bean:message key="ssm.overview.misc"/>:</b></th>
    <td>
      <p>
      <bean:message key="ssm.overview.misc.updateprofiles"/><br />
      <bean:message key="ssm.overview.misc.customvalues"/><br />
      <bean:message key="ssm.overview.misc.entitlements"/><br />
      <bean:message key="ssm.overview.misc.deletereboot"/><br />
      <bean:message key="ssm.overview.misc.migrate"/><br />
      <bean:message key="ssm.overview.misc.scap"/><br />
      </p>
    </td>
  </tr>

</table>


</body>
</html>
