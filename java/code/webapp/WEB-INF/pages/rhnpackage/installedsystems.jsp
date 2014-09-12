<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/package/package_header.jspf" %>

<h2>
<bean:message key="installedsystems.jsp.title"/>
</h2>

<p><bean:message key="installedsystems.jsp.summary"/></p>

<div>

<%-- rhn:list pageList="${requestScope.pageList}" noDataText="newversions.jsp.noversions">
  <rhn:listdisplay>
    <rhn:column header="installedsystems.jsp.errata">
      <a href="/rhn/systems/details/ErrataList.do?sid=${current.id}">${current.total_errata}</a>
    </rhn:column>

    <rhn:column header="installedsystems.jsp.packages">
      <a href="/rhn/systems/details/packages/UpgradableList.do?sid=${current.id}">${current.outdated_packages}</a>
    </rhn:column>

    <rhn:column header="installedsystems.jsp.system">
      <a href="/rhn/systems/details/Overview.do?sid=${current.id}">${current.server_name}</a>
    </rhn:column>

    <rhn:column header="installedsystems.jsp.entitlement">
      ${current.entitlement_level}
    </rhn:column>

  </rhn:listdisplay>
</rhn:list --%>
<rl:listset name="systemSet" legend="system-group">
<rhn:csrf />
  <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
</rl:listset>

</div>

</body>
</html:html>
