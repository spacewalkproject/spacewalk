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
            <i class="fa fa-lock"></i>
        </c:if>
        <c:if test="${current.bugFix}">
            <i class="fa fa-bug"></i>
        </c:if>
        <c:if test="${current.productEnhancement}">
            <i class="fa  spacewalk-icon-enhancement"></i>
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
