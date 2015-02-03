<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <h2><rhn:icon type="header-proxy" /><bean:message key="sdc.details.connection.header"/></h2>

    <p><bean:message key="sdc.details.connection.summary1"/></p>
    <p><bean:message key="sdc.details.connection.summary2"/></p>

    <rhn:list pageList="${requestScope.pageList}"
            noDataText="sdc.details.connection.empty">

      <rhn:listdisplay>
        <rhn:column header="sdc.details.connection.proxyorder">
          <c:out value="${current.position}" escapeXml="true" />
        </rhn:column>

        <rhn:column header="row.hostname">
          <c:out value="${current.hostname}" escapeXml="true" />
        </rhn:column>

        <rhn:column header="systemlist.jsp.entitlement">
          <c:out value="${current.entitlementLevel}" escapeXml="false" />
        </rhn:column>
      </rhn:listdisplay>

    </rhn:list>

  </body>
</html:html>
