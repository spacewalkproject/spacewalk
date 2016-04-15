<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <h2><rhn:icon type="header-proxy" /><bean:message key="sdc.details.proxyclients.header"/></h2>

    <c:choose>
      <c:when test="${requestScope.version != null}">
        <p><bean:message key="sdc.details.proxy.licensed" arg0="${requestScope.version}" /></p>
      </c:when>
      <c:otherwise>
        <p><bean:message key="sdc.details.proxy.unlicensed" /></p>
      </c:otherwise>
    </c:choose>

    <rhn:list pageList="${requestScope.pageList}"
            noDataText="sdc.details.proxyclients.empty">

      <rhn:listdisplay>
        <rhn:column header="systemlist.jsp.system">
          <c:out value="${current.name}" escapeXml="true" />
        </rhn:column>

        <rhn:column header="systemlist.jsp.entitlement">
          <c:out value="${current.entitlementLevel}" escapeXml="false" />
        </rhn:column>
      </rhn:listdisplay>

    </rhn:list>

  </body>
</html:html>
