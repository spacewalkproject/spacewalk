<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
<body>
  <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
  <rhn:toolbar base="h2" icon="header-snapshot-rollback">
    <bean:message key="ssm.provisioning.rollbacktotag.header" arg0="${param.tag_name}" />
  </rhn:toolbar>

  <div class="page-summary">
    <p><bean:message key="ssm.provisioning.rollbacktotag.summary1"
                   arg0="<strong>${param.tag_name}</strong>" /></p>
    <p><bean:message key="ssm.provisioning.rollbacktotag.summary2" /></p>
    <p><bean:message key="ssm.provisioning.rollbacktotag.note" /></p>
  </div>

  <rl:listset name="rollbackSet" legend="system-history">
    <rhn:csrf />
    <input type="hidden" name="tag_id" value="${param.tag_id}" />

    <rl:list styleclass="list" alphabarcolumn="server_name">
      <rl:decorator name="PageSizeDecorator" />

      <rl:column headerkey="column.name">
        <a href="/rhn/systems/details/Overview.do?sid=${current.id}"><c:out value="${current.server_name}" /></a>
      </rl:column>
      <rl:column headerkey="column.reason">
        <a href="/rhn/systems/details/history/snapshots/Index.do?sid=${current.id}&amp;ss_id=${current.snapshot_id}"><c:out value="${current.snapshot_reason}" /></a>
      </rl:column>
      <rl:column headerkey="ssm.provisioning.rollbacktotag.datetagapplied">
        ${current.date_tag_applied}
      </rl:column>
    </rl:list>

    <rhn:submitted/>
    <html:submit styleClass="btn btn-default pull-right" property="dispatch">
      <bean:message key="ssm.provisioning.rollbacktotag.rollback-button" />
    </html:submit>

  </rl:listset>

</body>
</html>
