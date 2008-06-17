<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif" imgAlt="errata.common.errataAlt"
 helpUrl="/rhn/help/reference/en/s2-sm-all-errata.jsp">
  <bean:message key="erratalist.jsp.allerrata"/>
</rhn:toolbar>

<form method="POST" name="rhn_list" action="/rhn/errata/AllErrataSubmit.do">
<rhn:list pageList="${requestScope.pageList}" noDataText="erratalist.jsp.noerrata"
          legend="errata">
  <rhn:listdisplay filterBy="erratalist.jsp.synopsis">
    <rhn:column header="erratalist.jsp.type" style="text-align: center;">
        <c:if test="${current.securityAdvisory}">
            <img src="/img/wrh-security.gif"
                 alt="<bean:message key='erratalist.jsp.securityadvisory' />"
                 title="<bean:message key='erratalist.jsp.securityadvisory' />" />
        </c:if>
        <c:if test="${current.bugFix}">
            <img src="/img/wrh-bug.gif"
                 alt="<bean:message key='erratalist.jsp.bugadvisory' />"
                 title="<bean:message key='erratalist.jsp.bugadvisory' />" />
        </c:if>
        <c:if test="${current.productEnhancement}">
            <img src="/img/wrh-product.gif"
                 alt="<bean:message key='erratalist.jsp.productenhancementadvisory' />"
                 title="<bean:message key='erratalist.jsp.productenhancementadvisory' />" />
        </c:if>
    </rhn:column>
    <rhn:column header="erratalist.jsp.advisory"
                url="/rhn/errata/details/Details.do?eid=${current.id}">
      ${current.advisoryName}
    </rhn:column>
    <rhn:column header="erratalist.jsp.synopsis">
      ${current.advisorySynopsis}
    </rhn:column>
    <rhn:column header="erratalist.jsp.systems" style="text-align: center;"
                url="/rhn/errata/details/SystemsAffected.do?eid=${current.id}"
                renderUrl="${current.affectedSystemCount > 0}">
      ${current.affectedSystemCount}
    </rhn:column>
    <rhn:column header="erratalist.jsp.updated" style="text-align: center;">
      ${current.updateDate}
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>
</form>
</body>
</html>
