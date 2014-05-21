<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>

    <body>
        <rhn:toolbar base="h1"
                     icon="header-system"
                     helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-systems-entitlements"
                     imgAlt="channels.jsp.alt">
            <bean:message key="entitledsystems.jsp.header"/>
        </rhn:toolbar>

        <div class="page-summary">
            <p>
                <c:choose>
                    <c:when test="${entitlementType == 'regular'}">
                        <bean:message key="entitledsystems.summary.regular" arg0="${requestScope.familyName}"/>
                    </c:when>
                    <c:when test="${entitlementType == 'flex'}">
                        <bean:message key="entitledsystems.summary.flex" arg0="${requestScope.familyName}"/>
                    </c:when>
                    <c:when test="${entitlementType == 'all'}">
                        <bean:message key="entitledsystems.summary.all" arg0="${requestScope.familyName}"/>
                    </c:when>
                </c:choose>
            </p>
        </div>

        <rl:listset name="systemListSet" legend="system">
            <rhn:csrf />
            <rhn:submitted />
            <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
        </rl:listset>
    </body>
</html>
