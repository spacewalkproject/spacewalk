<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot">
  ${param.snapshot_created} <bean:message key="system.history.snapshot.cfgFilesHeader" />
</rhn:toolbar>

<div class="page-summary">
  <bean:message key="system.history.snapshot.cfgFilesSummary" />
</div>

<rl:listset name="ChannelSet">
  <rhn:csrf />
  <rl:list emptykey="system.history.snapshot.cfgFilesEmpty">
    <rl:decorator name="PageSizeDecorator" />
    <rl:decorator name="ElaborationDecorator" />
    <rl:column headerkey="channelfiles.jsp.path">
      <a href="/rhn/configuration/file/FileDetails.do?crid=${current.id}">${current.path}</a>
    </rl:column>
    <rl:column headerkey="difffiles.jsp.revision">
      ${current.revision}
    </rl:column>
    <rl:column headerkey="system.history.snapshot.cfgFilesChecksum">
      ${current.checksum}
    </rl:column>
    <rl:column headerkey="system.jsp.customkey.created">
      ${current.created}
    </rl:column>
  </rl:list>
  <input type="hidden" name="sid" value="${param.sid}" />
  <input type="hidden" name="ss_id" value="${param.ss_id}" />
</rl:listset>

</body>
</html>
