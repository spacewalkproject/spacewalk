<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html >
<body>
<h2><bean:message key="erratalist.jsp.cloneerrata" /></h2>

<div class="page-summary">
    <p><bean:message key="cloneconfirm.jsp.pagesummary" arg0="/rhn/errata/manage/UnpublishedErrata.do" /></p>
</div>

<form method="post" name="rhn_list" action="/rhn/errata/manage/CloneConfirmSubmit.do">
<rhn:csrf />
<rhn:list pageList="${requestScope.pageList}" noDataText="erratalist.jsp.noerrata">
  <rhn:listdisplay button="deleteconfirm.jsp.confirm">
    <rhn:column header="erratalist.jsp.type">
    <c:if test="${current.securityAdvisory}">
    <c:choose>
    <c:when test="${current.severityid=='0'}">
        <rhn:icon type="errata-security-critical"
                  title="erratalist.jsp.securityadvisory"/>
    </c:when>
    <c:when test="${current.severityid=='1'}">
        <rhn:icon type="errata-security-important"
                  title="erratalist.jsp.securityadvisory"/>
    </c:when>
    <c:when test="${current.severityid=='2'}">
        <rhn:icon type="errata-security-moderate"
                  title="erratalist.jsp.securityadvisory"/>
    </c:when>
    <c:when test="${current.severityid=='3'}">
        <rhn:icon type="errata-security-low"
                  title="erratalist.jsp.securityadvisory"/>
    </c:when>
    <c:otherwise>
        <rhn:icon type="errata-security"
                  title="erratalist.jsp.securityadvisory"/>
    </c:otherwise>
    </c:choose>
    </c:if>
        <c:if test="${current.bugFix}">
            <rhn:icon type="errata-bugfix" />
        </c:if>
        <c:if test="${current.productEnhancement}">
            <rhn:icon type="errata-enhance" />
        </c:if>
    </rhn:column>
    <rhn:column header="erratalist.jsp.advisory">
      <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
    </rhn:column>
    <rhn:column header="erratalist.jsp.synopsis">
      ${current.advisorySynopsis}
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>

</body>
</html:html>
