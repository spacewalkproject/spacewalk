<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot">
    ${param.snapshot_created} <bean:message key="system.history.snapshot.header-channels" />
</rhn:toolbar>

<div class="page-summary">
    <p><bean:message key="system.history.snapshot.summary-channels" /></p>
</div>

<rl:listset name="eventSet" legend="system-history">
    <rhn:csrf />
    <rhn:hidden name="sid" value="${param.sid}" />
    <rhn:hidden name="ss_id" value="${param.ss_id}" />
    <rl:list emptykey="system.history.snapshot.nochanneldiff">

        <rl:decorator name="PageSizeDecorator" />
        <rl:decorator name="ElaborationDecorator" />

        <c:choose>
            <c:when test="${empty current.snapshot_channel_id}">
                <rl:column headerkey="system.history.snapshot.channel.list">
                    <a href="/rhn/channels/ChannelDetail.do?cid=${current.current_channel_id}">
                        ${current.current_channel_label}
                   </a>
                </rl:column>
                <rl:column headerkey="system.history.snapshot.channel.subscription">
                    <bean:message key="grouplist.jsp.groupmembership.current" />
                </rl:column>
            </c:when>

            <c:when test="${empty current.current_channel_id}">
                <rl:column headerkey="system.history.snapshot.channel.list">
                    <a href="/rhn/channels/ChannelDetail.do?cid=${current.current_channel_id}">
                        ${current.snapshot_channel_label}
                    </a>
                </rl:column>
                <rl:column headerkey="system.history.snapshot.channel.subscription">
                    <bean:message key="grouplist.jsp.groupmembership.snapshot" />
                </rl:column>
            </c:when>
        </c:choose>
    </rl:list>
</rl:listset>

</body>
</html>
