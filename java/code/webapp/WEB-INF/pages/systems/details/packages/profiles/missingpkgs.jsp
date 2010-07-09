<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>


<h2>
    <bean:message key="missingpkgs.jsp.missingpackages" />
</h2>

<rl:listset name="compareListSet">
    <div class="page-summary">
        <bean:message key="missingpkgs.jsp.pagesummary" />
    </div>

    <rl:list width="100%"
        name="compareList"
        styleclass="list">

        <rl:column headerkey="missingpkgs.jsp.package" bound="false">
            ${current.actionTargetNevra}
        </rl:column>

        <rl:column headerkey="missingpkgs.jsp.channels" bound="false">
            <c:choose>
                <c:when test="${empty current.channels}">
                    <bean:message key="missingpkgs.jsp.none" />
                </c:when>
                <c:when test="${!empty current.channels}">
                    <c:forEach items="${current.channels}" var="item">
                        ${item.name}<br />
                    </c:forEach>
                </c:when>
            </c:choose>
        </rl:column>
    </rl:list>

    <rhn:submitted/>
    <div align="right">
        <hr />
        <html:submit property="dispatch">
            <bean:message key="missingpkgs.jsp.selectnewpackageprofile" />
        </html:submit>
        <html:submit property="dispatch">
            <bean:message key="missingpkgs.jsp.removelistedpackagesfromsync" />
        </html:submit>
        <html:submit property="dispatch">
            <bean:message key="missingpkgs.jsp.subscribetochannels" />
        </html:submit>
    </div>

    <html:hidden property="sid" value="${param.sid}" />
    <html:hidden property="sid_1" value="${param.sid_1}" />
    <html:hidden property="prid" value="${param.prid}" />
    <html:hidden property="sync" value="${param.sync}" />
    <html:hidden property="set_label" value="packages_for_system_sync" />
    <html:hidden property="time" value="${time}" />

</rl:listset>

</body>
</html>
