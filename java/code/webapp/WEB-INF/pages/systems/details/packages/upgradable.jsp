<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

  <h2>
    <img src="/img/rhn-icon-package-upgrade.gif"
         alt="<bean:message key='errata.common.upgradepackageAlt' />" />
    <bean:message key="upgradable.jsp.header" />
  </h2>
  <div class="page-summary">
    <p>
      <bean:message key="upgradable.jsp.summary" />
    </p>
  </div>

<form method="POST" name="rhn_list" action="/rhn/systems/details/packages/UpgradableListSubmit.do?sid=${param.sid}">
<rhn:list pageList="${requestScope.pageList}" noDataText="upgradable.jsp.nopackages">
  <rhn:listdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}" 
                   filterBy="upgradable.jsp.latest" button="upgradable.jsp.upgrade">
    <rhn:set element="${current.idOne}" elementTwo="${current.idTwo}" />
    <rhn:column header="upgradable.jsp.latest"
                url="/rhn/software/packages/Details.do?sid=${param.sid}&amp;id_combo=${current.idCombo}">
      ${current.nvre}
    </rhn:column>
    <rhn:column header="upgradable.jsp.installed">
      <c:forEach items="${current.installed}" var="package">
        ${package} <br/>
      </c:forEach>
    </rhn:column>
    <rhn:column header="upgradable.jsp.errata">
      <c:forEach items="${current.errata}" var="errata">
        <c:if test="${not empty errata.advisory}">
          <c:if test="${errata.type == 'Security Advisory'}">
            <img src="/img/wrh-security.gif"
                 alt="<bean:message key='erratalist.jsp.securityadvisory' />"
                 title="<bean:message key='erratalist.jsp.securityadvisory' />" />
          </c:if>
          <c:if test="${errata.type == 'Bug Fix Advisory'}">
            <img src="/img/wrh-bug.gif"
                 alt="<bean:message key='erratalist.jsp.bugadvisory' />"
                 title="<bean:message key='erratalist.jsp.bugadvisory' />" />
          </c:if>
          <c:if test="${errata.type == 'Product Enhancement Advisory'}">
            <img src="/img/wrh-product.gif"
                 alt="<bean:message key='erratalist.jsp.productenhancementadvisory' />"
                 title="<bean:message key='erratalist.jsp.productenhancementadvisory' />" />
          </c:if>
          <a href="/rhn/errata/details/Details.do?eid=${errata.id}">${errata.advisory}</a><br/>
        </c:if>
      </c:forEach>
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>

</form>
</body>
</html>
