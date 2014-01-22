<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>

<html>
<body>
    <rhn:toolbar base="h1" icon="header-chain"
        helpUrl="/rhn/help/reference/en-US/s1-sm-actions.jsp#s2-sm-action-chains">
        <bean:message key="actionchains.jsp.title" />
    </rhn:toolbar>

    <p>
        <bean:message key="actionchains.jsp.summary" />
    </p>
    <p>
        <bean:message key="actionchains.jsp.summarydetail" />
    </p>

    <rl:listset name="list">
        <rhn:csrf />

        <rl:list emptykey="actionchains.jsp.empty" styleclass="list"
            alphabarcolumn="label">
            <rl:decorator name="PageSizeDecorator" />

            <rl:column sortable="true" bound="false"
                headerkey="actionchains.jsp.label" sortattr="label"
                defaultsort="asc" filterattr="label" styleclass="list-fat-column-50">
                <a href="/rhn/schedule/ActionChain.do?id=${current.id}">
                    <c:out value="${current.label}" escapeXml="true" />
                </a>
            </rl:column>

            <rl:column sortable="true" bound="false"
                headerkey="actionchains.jsp.created" sortattr="created">
                <c:out value="${current.localizedCreated}" />
            </rl:column>

            <rl:column sortable="true" bound="false"
                headerkey="actionchains.jsp.modified" sortattr="modified">
                <c:out value="${current.localizedModified}" />
            </rl:column>
        </rl:list>
        <rhn:submitted />
    </rl:listset>
</body>
</html>
