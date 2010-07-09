<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">
    <body>

<script type="text/javascript">
<!--
    function toggle_visibility(id) {
       var e = document.getElementById(id);
       if(e.style.display == 'block')
          e.style.display = 'none';
       else
          e.style.display = 'block';
    }
//-->
</script>

        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2>
            <bean:message key="basesub.jsp.confirm.header"/>
        </h2>

        <bean:message key="basesub.jsp.confirm.header.description"/>

        <c:if test="${foundUnmatchedChannels}">
            <h3><bean:message key="basesub.jsp.confirm.unmatchedHeader"/></h3>

            <bean:message key="basesub.jsp.confirm.unmatchedDescription"/> *<p/>

            <rl:listset name="unmatchedChannelSet">
                <rl:list dataset="unmatched_child_channels"
                         width="100%"
                         name="unmatchedChannels"
                         styleclass="list"
                         emptykey="basesub.jsp.confirm.noChannelsFound">

                    <rl:column bound="false"
                        sortable="false"
                        headerkey="basesub.jsp.confirm.header.oldChannel"
                        styleclass="first-column">
                        <a href="/rhn/channels/ChannelDetail.do?cid=${current.oldChannelId}">
                            ${current.oldChannelName}
                        </a>
                    </rl:column>

                    <rl:column bound="false"
                        sortable="false"
                        attr="otherChannelName"
                        headerkey="basesub.jsp.confirm.header.parentChannel">
                        <a href="/rhn/channels/ChannelDetail.do?cid=${current.otherChannelId}">
                            ${current.otherChannelName}
                        </a>
                    </rl:column>

                    <rl:column bound="false"
                        sortable="false"
                        headerkey="basesub.jsp.confirm.header.systemsAffected"
                        styleclass="last-column"
                        attr="systemsAffectedCount">

                        ${current.systemsAffectedCount}
                        <a id="show-sys-list-link-${current.oldChannelId}" style="display:block;" onclick="toggle_visibility('sys-list-for-child-${current.oldChannelId}');toggle_visibility('show-sys-list-link-${current.oldChannelId}');toggle_visibility('hide-sys-list-link-${current.oldChannelId}');">
                            <bean:message key="basesub.jsp.confirm.clickToShowSystems"/>
                        </a>
                        <br/>
                        <div id="sys-list-for-child-${current.oldChannelId}" style="display:none;">
                            <c:forEach items="${current.systemsAffected}" var="sys">
                            <img src="/img/branch.gif"/> <a href="/rhn/systems/details/Overview.do?sid=${sys['id']}">${sys['name']}</a><br/>
                            </c:forEach>
                        </div>
                        <a id="hide-sys-list-link-${current.oldChannelId}" style="display:none;" onclick="toggle_visibility('sys-list-for-child-${current.oldChannelId}');toggle_visibility('show-sys-list-link-${current.oldChannelId}');toggle_visibility('hide-sys-list-link-${current.oldChannelId}');">
                            <bean:message key="basesub.jsp.confirm.clickToHideSystems"/>
                        </a>
                    </rl:column>

                </rl:list>
            </rl:listset>
        </c:if>

        <h3><bean:message key="basesub.jsp.confirm.matchedHeader"/></h3>

        <bean:message key="basesub.jsp.confirm.matchedDescription"/><p/>

        <rl:listset name="matchedChannelSet">
            <rl:list dataset="matched_child_channels"
                     width="100%"
                     name="matchedChannels"
                     styleclass="list"
                     emptykey="basesub.jsp.confirm.noChannelsFound">

                <rl:column bound="false"
                    sortable="false"
                    headerkey="basesub.jsp.confirm.header.oldChannel"
                    styleclass="first-column">
                    <a href="/rhn/channels/ChannelDetail.do?cid=${current.oldChannelId}">
                        ${current.oldChannelName}
                    </a>
                </rl:column>

                <rl:column bound="false"
                    sortable="false"
                    attr="otherChannelName"
                    headerkey="basesub.jsp.confirm.header.newChannel">
                    <a href="/rhn/channels/ChannelDetail.do?cid=${current.otherChannelId}">
                        ${current.otherChannelName}
                    </a>
                </rl:column>

                <rl:column bound="false"
                    sortable="false"
                    headerkey="basesub.jsp.confirm.header.systemsAffected"
                    styleclass="last-column"
                    attr="systemsAffectedCount">

                    ${current.systemsAffectedCount}
                    <a id="show-sys-list-link-${current.oldChannelId}" style="display:block;" onclick="toggle_visibility('sys-list-for-child-${current.oldChannelId}');toggle_visibility('show-sys-list-link-${current.oldChannelId}');toggle_visibility('hide-sys-list-link-${current.oldChannelId}');">
                        <bean:message key="basesub.jsp.confirm.clickToShowSystems"/>
                    </a>
                    <br/>
                    <div id="sys-list-for-child-${current.oldChannelId}" style="display:none;">
                        <c:forEach items="${current.systemsAffected}" var="sys">
                        <img src="/img/branch.gif"/> <a href="/rhn/systems/details/Overview.do?sid=${sys['id']}">${sys['name']}</a><br/>
                        </c:forEach>
                    </div>
                    <a id="hide-sys-list-link-${current.oldChannelId}" style="display:none;" onclick="toggle_visibility('sys-list-for-child-${current.oldChannelId}');toggle_visibility('show-sys-list-link-${current.oldChannelId}');toggle_visibility('hide-sys-list-link-${current.oldChannelId}');">
                        <bean:message key="basesub.jsp.confirm.clickToHideSystems"/>
                    </a>
                </rl:column>

            </rl:list>
        </rl:listset>

        <p/>

        <html:form method="post" action="/channel/ssm/BaseChannelSubscribe.do">
            <div align="right">
                <html:hidden property="submitted" value="true"/>

                <html:hidden property="base_channel_ids" value="${base_channel_ids}"/>
                <html:hidden property="new_base_channel_ids" value="${new_base_channel_ids}"/>

                <html:submit property="dispatch">
                    <bean:message key="basesub.jsp.confirm.cancel"/>
                </html:submit>

                <html:submit property="dispatch">
                    <bean:message key="basesub.jsp.confirm.alter"/>
                </html:submit>
            </div>
        </html:form>

        <p/>
        <span class="small-text"><bean:message key="basesub.jsp.confirm.fasTrackBetaNote"/></span>

    </body>
</html:html>


