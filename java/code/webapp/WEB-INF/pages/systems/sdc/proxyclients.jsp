<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
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

	<rl:listset name="systemListSet" legend="system">

	    <rl:list dataset="pageList" name="systemList" emptykey="nosystems.message" alphabarcolumn="name">

             <rl:selectablecolumn value="${current.id}" selected="${current.selected}"/>

             <!-- Name Column -->
             <rl:column sortable="true"
                        bound="false"
                        headerkey="systemlist.jsp.system"
                        sortattr="name"
                        defaultsort="asc"
                        styleclass="${namestyle}">
                 <a href="/rhn/systems/details/Overview.do?sid=${current.id}">${fn:escapeXml(current.name)}</a>
             </rl:column>

             <!-- Entitlement Column -->
             <rl:column sortable="false"
                        bound="false"
                        headerkey="systemlist.jsp.entitlement">
                  <c:out value="${current.entitlementLevel}" escapeXml="false"/>
             </rl:column>

	    </rl:list>
    </rl:listset>
  </body>
</html:html>
