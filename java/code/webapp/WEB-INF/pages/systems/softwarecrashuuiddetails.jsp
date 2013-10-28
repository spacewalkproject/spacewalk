<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c-rt" %>

<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
    <rhn:toolbar base="h1" img="/img/rhn-icon-bug-ex.gif">
        <bean:message key="software.crashes"/>
    </rhn:toolbar>

    <div class="toolbar-h2">
        <bean:message key="software.crashes.uuid.header"/>
    </div>

    <br />

    <table class="details">
        <tr>
            <th><bean:message key="crashes.jsp.uuid"/></th>
            <td><c:out value="${crashesSummary.uuid}"/></td>
        </tr>
        <tr>
            <th><bean:message key="crashes.jsp.totalcrashcount"/></th>
            <td><c:out value="${crashesSummary.totalCrashCount}"/></td>
        </tr>
        <tr>
            <th><bean:message key="crashes.jsp.affectedsystemscount"/></th>
            <td><c:out value="${crashesSummary.systemCount}"/></td>
        </tr>
        <tr>
            <th><bean:message key="crashes.jsp.lastoccurence"/></th>
            <td><c:out value="${crashesSummary.lastCrashReport}"/></td>
        </tr>
    </table>

    <hr />
    <div class="page-summary">
        <p><bean:message key="software.crashes.by.uuid.summary"/></p>
    </div>

    <rl:listset name="crashServers">
        <rhn:csrf />
        <rhn:submitted />
        <input type="hidden" name="uuid" value="${crashesSummary.uuid}"/>

        <div class="full-width-wrapper" style="clear: both;">
            <rl:list emptykey="nosystems.message"
                     alphabarcolumn="serverName">
                <rl:decorator name="PageSizeDecorator"/>
                <rl:column headerkey="systemlist.jsp.system"
                           bound="false"
                           sortattr="serverName"
                           sortable="true"
                           filterattr="serverName">
                    <a href="/rhn/systems/details/SoftwareCrashDetail.do?crid=${current.crashId}&sid=${current.serverId}">
                        <c:out value="${current.serverName}" escapeXml="true" />
                    </a>
                </rl:column>
                <rl:column headerkey="crashes.jsp.crashcount"
                           bound="false"
                           sortattr="crashCount"
                           sortable="true">
                    ${current.crashCount}
                </rl:column>
                <rl:column headerkey="crashes.jsp.component"
                           bound="false"
                           sortattr="crashComponent"
                           sortable="true">
                    ${current.crashComponent}
                </rl:column>
                <rl:column headerkey="crashes.jsp.lastoccurence"
                           bound="false"
                           sortattr="lastReport"
                           sortable="true">
                    ${current.lastReport}
                </rl:column>
            </rl:list>
        </div>
        <rl:csv name="crashServers"
                exportColumns="serverName,crashCount,crashComponent,lastReport" />
    </rl:listset>
</body>
</html>
