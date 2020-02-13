<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

  <h2>
    <rhn:icon type="header-package-upgrade" title="errata.common.upgradepackageAlt" />
    <bean:message key="upgradable.jsp.header" />
  </h2>
  <div class="page-summary">
    <p>
      <bean:message key="upgradable.jsp.summary" />
    </p>
  </div>

<c:set var="pageList" value="${requestScope.all}" />

<rl:listset name="packageListSet">
    <rhn:csrf />
    <rhn:submitted />
        <rl:list dataset="pageList"
         width="100%"
         name="packageList"
         emptykey="packagelist.jsp.nopackages"
         alphabarcolumn="nvrea">
                        <rl:decorator name="PageSizeDecorator"/>
                        <rl:decorator name="ElaborationDecorator"/>
                <rl:decorator name="SelectableDecorator"/>
                        <rl:selectablecolumn value="${current.selectionKey}"
                                selected="${current.selected}"
                                disabled="${not current.selectable}"/>

                  <rl:column headerkey="upgradable.jsp.latest" bound="false"
                        sortattr="nvrea"
                        sortable="true" filterattr="nvrea">

                      <a href="/rhn/software/packages/Details.do?sid=${param.sid}&amp;id_combo=${current.idCombo}">
                        ${current.nvrea}</a>
                  </rl:column>

                  <rl:column headerkey="upgradable.jsp.installed" bound="false">
                      ${current.installedPackage}
                  </rl:column>

    <rl:column headerkey="upgradable.jsp.errata">
      <c:forEach items="${current.errata}" var="errata">
        <c:if test="${not empty errata.advisory}">
          <c:if test="${errata.type == 'Security Advisory'}">
              <c:choose>
                  <c:when test="${errata.severity=='0'}">
                      <rhn:icon type="errata-security-critical"
                                title="erratalist.jsp.securityadvisory" />
                  </c:when>
                  <c:when test="${errata.severity=='1'}">
                      <rhn:icon type="errata-security-important"
                                title="erratalist.jsp.securityadvisory" />
                  </c:when>
                  <c:when test="${errata.severity=='2'}">
                      <rhn:icon type="errata-security-moderate"
                                title="erratalist.jsp.securityadvisory" />
                  </c:when>
                  <c:when test="${errata.severity=='3'}">
                      <rhn:icon type="errata-security-low"
                                title="erratalist.jsp.securityadvisory" />
                  </c:when>
                  <c:otherwise>
                      <rhn:icon type="errata-security"
                                title="erratalist.jsp.securityadvisory" />
                  </c:otherwise>
              </c:choose>

          </c:if>
          <c:if test="${errata.type == 'Bug Fix Advisory'}">
            <rhn:icon type="errata-bugfix" title="erratalist.jsp.bugadvisory" />
          </c:if>
          <c:if test="${errata.type == 'Product Enhancement Advisory'}">
            <rhn:icon type="errata-enhance" title="erratalist.jsp.productenhancementadvisory" />
          </c:if>
          <a href="/rhn/errata/details/Details.do?eid=${errata.id}">${errata.advisory}</a><br/>
        </c:if>
      </c:forEach>
    </rl:column>
</rl:list>

<c:if test="${not empty requestScope.all}">
    <rhn:submitted/>
    <div class="text-right">
                <hr />
                <input type="submit" class="btn btn-success" name ="dispatch" value='<bean:message key="upgradable.jsp.upgrade"/>'/>
    </div>
</c:if>
</rl:listset>
</body>
</html>
