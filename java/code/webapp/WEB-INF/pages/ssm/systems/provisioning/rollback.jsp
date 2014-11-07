<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
<body>
  <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
  <rhn:toolbar base="h2" icon="header-snapshot-rollback">
    <bean:message key="ssm.provisioning.rollback.header" />
  </rhn:toolbar>

  <div class="page-summary">
    <p><bean:message key="ssm.provisioning.rollback.summary1" /></p>
    <p><bean:message key="ssm.provisioning.rollback.summary2" /></p>
  </div>

  <rl:listset name="tagSet">

    <rl:list styleclass="list" alphabarcolumn="server_name">
      <rl:decorator name="PageSizeDecorator" />

      <rl:column headerkey="column.tag-name">
        <a href="/rhn/systems/ssm/provisioning/RollbackToTag.do?tag_id=${current.id}"><c:out value="${current.name}" /></a>
      </rl:column>
      <rl:column headerkey="column.tagged-systems">
        <c:out value="${current.tagged_systems}" />
      </rl:column>
      <rl:column headerkey="column.tag-created">
        ${current.date_tag_created}
      </rl:column>
    </rl:list>

  </rl:listset>

</body>
</html>
