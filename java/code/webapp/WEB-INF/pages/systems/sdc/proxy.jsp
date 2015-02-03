<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <h2><rhn:icon type="header-proxy" /><bean:message key="sdc.details.proxy.header"/></h2>

    <c:choose>
      <c:when test="${requestScope.version != null}">
        <p><bean:message key="sdc.details.proxy.licensed" arg0="${requestScope.version}" /></p>
      </c:when>
      <c:otherwise>
        <p><bean:message key="sdc.details.proxy.unlicensed" /></p>
      </c:otherwise>
    </c:choose>

  </body>
</html:html>
