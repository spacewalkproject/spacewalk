<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<head>
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/groups/header.jspf" %>

<h2>
    <bean:message key="systemgroup.erratalist.title" />
</h2>

<div class="page-summary">
<bean:message key="systemgroup.erratalist.summary" />
</div>

<rl:listset name="groupSet" legend="errata">
    <rhn:csrf />
    <input type="hidden" name="sgid" value="${systemgroup.id}" />

    <rl:list emptykey="erratalist.jsp.noerrata">

        <rl:decorator name="PageSizeDecorator" />
        <rl:decorator name="ElaborationDecorator" />

        <rl:column headerkey="erratalist.jsp.type" styleclass="text-align: left;">
            <c:if test="${current.securityAdvisory}">
                <rhn:icon type="errata-security" title="erratalist.jsp.securityadvisory" />
            </c:if>
            <c:if test="${current.bugFix}">
                <rhn:icon type="errata-bugfix" title="erratalist.jsp.bugadvisory" />
            </c:if>
            <c:if test="${current.productEnhancement}">
                <rhn:icon type="errata-enhance" title="erratalist.jsp.productenhancementadvisory" />
            </c:if>
        </rl:column>
        <rl:column headerkey="erratalist.jsp.advisory">
            <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
        </rl:column>
        <rl:column headerkey="erratalist.jsp.synopsis"
                   sortable="true"
                   sortattr="advisorySynopsis"
                   filterattr="advisorySynopsis">
            ${current.advisorySynopsis}
        </rl:column>
        <rl:column headerkey="erratalist.jsp.systems"
                   styleclass="text-align: center;">
            <a href="/rhn/groups/SystemsAffected.do?sgid=${systemgroup.id}&amp;eid=${current.id}">${current.affectedSystemCount}</a>
        </rl:column>
        <c:if test="${displayCves}">
            <rl:column headerkey="erratalist.jsp.updated"
                       sortable="true"
                       sortattr="updateDateObj"
                       styleclass="text-align: center;">
                ${current.updateDate}
            </rl:column>
        </c:if>
        <c:if test="${not displayCves}">
              <rl:column headerkey="erratalist.jsp.updated"
                sortable="true"
                sortattr="updateDateObj"
                styleclass="text-align: center;">
                ${current.updateDate}
            </rl:column>
        </c:if>

    </rl:list>
</rl:listset>

</body>
</html>
