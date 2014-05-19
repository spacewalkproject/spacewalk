<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot">
  <bean:message key="system.history.snapshot.tagCreateHeader" />
</rhn:toolbar>

<div class="page-summary">
  <p><bean:message key="system.history.snapshot.tagCreateSummary" /></p>
</div>

<html:form method="post" action="/systems/details/history/snapshots/SnapshotTagCreate.do?sid=${system.id}&ss_id=${param.ss_id}">

<rhn:csrf/>
<html:hidden property="submitted" value="true" />

<strong><bean:message key="system.history.snapshot.tagName" />:</strong>
<html:text property="tagName" maxlength="256" styleClass="form-control" />

<hr/>

<input type="hidden" name="sid" value="${param.sid}"/>
<input type="hidden" name="ss_id" value="${param.ss_id}"/>
<input type="submit" name="dispatch" class="btn btn-default pull-right"
      value='<bean:message key="system.history.snapshot.tagCreate"/>'/>

</html:form>

</body>
</html>
