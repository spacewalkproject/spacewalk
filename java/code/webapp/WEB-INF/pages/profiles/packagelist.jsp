<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/profile/header.jspf" %>
<div class="page-summary">
    <p><bean:message key="profile.packagelist.summary"/></p>
</div>

<rl:listset name="groupSet">

    <rl:list dataset="pageList"
             width="100%"
             styleclass="list"
             emptykey="packagelist.jsp.nopackages"
             alphabarcolumn="nvre">

        <rl:decorator name="PageSizeDecorator"/>

        <rl:column headerkey="column.package" bound="false" filterattr="nvre">
            <c:out value="${current.nvre}" escapeXml="false"/>
        </rl:column>

        <rl:column headerkey="column.architecture" bound="false"
                   styleclass="thin-column last-column">
            <c:choose>
                <c:when test="${not empty current.arch}">${current.arch}</c:when>
                <c:otherwise><bean:message
                        key="packagelist.jsp.notspecified"/></c:otherwise>
            </c:choose>
        </rl:column>

    </rl:list>

</rl:listset>

</body>
</html>
