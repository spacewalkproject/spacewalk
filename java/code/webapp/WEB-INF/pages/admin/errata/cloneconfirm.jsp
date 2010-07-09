<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:html xhtml="true">
<body>
<h2><bean:message key="erratalist.jsp.cloneerrata" /></h2>

<div class="page-summary">
    <p><bean:message key="cloneconfirm.jsp.pagesummary" arg0="/rhn/errata/manage/UnpublishedErrata.do" /></p>
</div>

<form method="post" name="rhn_list" action="/rhn/errata/manage/CloneConfirmSubmit.do">
<rhn:list pageList="${requestScope.pageList}" noDataText="erratalist.jsp.noerrata">
  <rhn:listdisplay button="deleteconfirm.jsp.confirm">
    <rhn:column header="erratalist.jsp.type">
        <c:if test="${current.securityAdvisory}">
            <img src="/img/wrh-security.gif"
                 title="<bean:message key="erratalist.jsp.securityadvisory"/>" />
        </c:if>
        <c:if test="${current.bugFix}">
            <img src="/img/wrh-bug.gif"
                 title="<bean:message key="erratalist.jsp.bugadvisory"/>" />
        </c:if>
        <c:if test="${current.productEnhancement}">
            <img src="/img/wrh-product.gif"
                 title="<bean:message key="erratalist.jsp.productenhancementadvisory"/>" />
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