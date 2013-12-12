<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

	<h2>
		<rhn:icon type="header-package-del" />
		<bean:message key="patchsetlist.jsp.patchsets" />
	</h2>
	<div class="page-summary">
		<p>
		<bean:message key="patchsetlist.jsp.patchsets_summary" />
		</p>
	</div>

<form method="POST" name="rhn_list" action="/rhn/systems/details/packages/patchsets/PatchSetListSubmit.do">
<rhn:csrf />
<rhn:list pageList="${requestScope.pageList}" noDataText="patchsetlist.jsp.nopatchsets" >
  <rhn:listdisplay filterBy="patchsetlist.jsp.patchsetname">
    <rhn:column header="patchsetlist.jsp.patchsetname"
                url="/rhn/systems/details/packages/patchsets/InstallPatchSet.do?sid=${param.sid}&pid=${current.id}">
      ${current.name}
    </rhn:column>
    <rhn:column header="patchsetlist.jsp.patchsetdate">
      ${current.setDate}
    </rhn:column>
    <rhn:column header="patchsetlist.jsp.patchsetactiontimestamp">
      ${current.latestActionTimestamp}
    </rhn:column>
    <rhn:column header="patchsetlist.jsp.patchsetactionstatus">
      ${current.latestActionStatus}
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>
<input type="hidden" name="sid" value="${param.sid}" />
</form>
</body>
</html>
