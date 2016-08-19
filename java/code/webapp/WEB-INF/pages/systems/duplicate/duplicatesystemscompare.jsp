<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
<script type="text/javascript">

        function toggleElement(row) {
                if (row.style.display == '') {
                         row.style.display = 'none';
                }
                else {
                 row.style.display = '';
                 }
        }


        function pageToggleRows(linkId, ids){
                for (var i = 0 ; i < ids.length; i++) {
                        toggleElement(document.getElementById(ids[i]));
                }
                toggleElement(document.getElementById(linkId + 'Show'));
                toggleElement(document.getElementById(linkId + 'Hide'));
        }

        function handle_delete(div_del_id, div_confirm_id, form) {
            var div_del = document.getElementById(div_del_id);
            var div_confirm = document.getElementById(div_confirm_id);
            div_del.style.display = 'none';
                div_confirm.style.display = '';
                return false;
        }

</script>
</head>
<body>
<rhn:toolbar base="h1" icon="header-system" imgAlt="system.common.systemAlt"
 helpUrl="">
  <bean:message key="duplicates.jsp.header"/>
</rhn:toolbar>

<c:set var="nosystemicons" value="true"/>

<h2><bean:message key="duplicate.compare.jsp.header"/></h2>
<rl:listset name="DupesCompareSet" legend="system">
<rhn:csrf />
                <p><bean:message key="duplicate.compares.jsp.message" arg0="${requestScope.maxLimit}"/>.</p>
<rl:list
        emptykey="nosystems.message"
                alphabarcolumn="name"
                filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter"
        >
        <rl:decorator name="SelectableDecorator"/>
        <rl:decorator name="PageSizeDecorator"/>
        <rl:selectablecolumn value="${current.id}"/>

        <!-- Name Column -->
        <rl:column headerkey="systemlist.jsp.system" sortable="true" bound="false" sortattr="name"
                           defaultsort="asc">
                <%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>
        </rl:column>
        <rl:column sortattr="lastCheckinDate"
                                        attr="lastCheckin"
                                        bound="true"
                                   headerkey="systemlist.jsp.last_checked_in"/>

</rl:list>
  <rhn:hidden name="key" value="${param.key}"/>
  <rhn:hidden name="key_type" value="${param.key_type}"/>

  <div class="text-right">
    <hr />
    <button type="submit" class="btn btn-default" name="refresh"><rhn:icon type="header-refresh" /> <bean:message key='Refresh Comparison'/></button>
  </div>
<rhn:submitted/>
<br/>
<h2><bean:message key='System Comparison'/></h2>
<c:choose> <c:when test="${requestScope.systems.size > 0}">
<table cellpadding="0" cellspacing="0" class="list compare-list">
        <thead><tr>
        <th> Property</th>
        <c:forEach items="${requestScope.systems.servers}" var="current">
                <th><%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %></th>
        </c:forEach>
        </tr></thead>
        <tbody>
        <tr class="list-button-row" >
                <td><%-- Empty --%></td>
                <c:forEach items="${requestScope.systems.systemIds}" var="current" varStatus="loop">
                        <c:choose>
                                <c:when test ="${loop.last}">
                                <td>
                                </c:when>
                                <c:otherwise><td></c:otherwise>
                        </c:choose>
                                <div style="display:none" id='div_confirm${current.value}'><input type="submit" class="btn btn-danger" name="btn${current.value}" value="${rhn:localize('ssm.delete.systems.confirmbutton')}"/></div>
                                <div id='div_del${current.value}'><input type="submit" class="btn btn-danger" name="delbtn${current.value}" value="${rhn:localize('Delete System Profile')}"
                                                                         onclick="return handle_delete('div_del${current.value}','div_confirm${current.value}', this.form);"/></div>
                                </td>
                </c:forEach>
        </tr>
        <tr>
                <td colspan="${requestScope.systems.size + 1}"><bean:message key="System Identity Properties"/>&nbsp;
                         <a  id='sysIdHide' href="javascript:pageToggleRows('sysId', ['lastCheckinRow', 'macAddressRow','ipAddressRow','ipv6AddressRow','systemGroupsRow'])"><bean:message key="Click Here To Hide"/> </a>
                         <a  style="display:none" id='sysIdShow' href="javascript:pageToggleRows('sysId', ['lastCheckinRow', 'macAddressRow','ipAddressRow','ipv6AddressRow','systemGroupsRow'])"><bean:message key="Click Here To Show"/> </a>
            </td>
        </tr>
        <tr class="list-row-odd" id="lastCheckinRow">
                <c:set var ="key" value="systemlist.jsp.last_checked_in"/>
                <c:set var ="items_list" value="${requestScope.systems.lastCheckinDates}"/>
                <c:set var ="href" value=""/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list.jspf" %>
        </tr>
        <tr class="list-row-even" id="macAddressRow">
                <c:set var ="key" value="row.macaddress"/>
                <c:set var ="items_list" value="${requestScope.systems.macAddresses}"/>
                <c:set var ="href" value=""/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        <tr class="list-row-odd" id = "ipAddressRow">
                <c:set var ="key" value="row.ip"/>
                <c:set var ="items_list" value="${requestScope.systems.ipAddresses}"/>
                <c:set var ="href" value=""/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        <tr class="list-row-even" id = "ipv6AddressRow">
                <c:set var ="key" value="row.ipv6"/>
                <c:set var ="items_list" value="${requestScope.systems.ipv6Addresses}"/>
                <c:set var ="href" value=""/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        <tr class="list-row-odd"  id = "systemGroupsRow">
                <c:set var ="key" value="System Groups"/>
                <c:set var ="items_list" value="${requestScope.systems.systemGroups}"/>
                <c:set var ="href" value="/rhn/groups/GroupDetail.do?sgid="/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        <tr>
                <td colspan="${requestScope.systems.size + 1}"><bean:message key="Extended System Identity Properties"/> &nbsp;
                         <a  id='extendedSysIdHide' href="javascript:pageToggleRows('extendedSysId', ['registrationDateRow', 'systemIdRow','activationKeysRow'])"><bean:message key="Click Here To Hide"/> </a>
                         <a  style="display:none" id='extendedSysIdShow' href="javascript:pageToggleRows('sysId', ['registrationDateRow', 'systemIdRow','activationKeysRow'])"><bean:message key="Click Here To Show"/> </a>
       </td>
        </tr>
        <tr class="list-row-odd" id = "registrationDateRow">
                <c:set var ="key" value="Registration Date"/>
                <c:set var ="items_list" value="${requestScope.systems.registrationDates}"/>
                <c:set var ="href" value=""/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list.jspf" %>
        </tr>
        <tr class="list-row-even" id = "systemIdRow">
                <c:set var ="key" value="System ID"/>
                <c:set var ="items_list" value="${requestScope.systems.systemIds}"/>
                <c:set var ="href" value=""/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list.jspf" %>
        </tr>

        <tr class="list-row-odd" id = "activationKeysRow">
                <c:set var ="key" value="Activation Keys"/>
                <c:set var ="items_list" value="${requestScope.systems.activationKeys}"/>
                <c:set var ="href" value="/rhn/activationkeys/Edit.do?tid="/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        <tr>
                <td colspan="${requestScope.systems.size + 1}"><bean:message key="System Content"/> &nbsp;
                         <a  id='sysContentIdHide' href="javascript:pageToggleRows('sysContentId', ['baseChannelRow', 'childChannelsRow','configChannelsRow'])"><bean:message key="Click Here To Hide"/> </a>
                         <a  style="display:none" id='sysContentIdShow' href="javascript:pageToggleRows('sysContentId', ['baseChannelRow', 'childChannelsRow','configChannelsRow'])"><bean:message key="Click Here To Show"/> </a>
            </td>
        </tr>

        <tr class="list-row-odd" id = "baseChannelRow">
                <c:set var ="key" value="kickstart.channel.label.jsp"/>
                <c:set var ="items_list" value="${requestScope.systems.baseChannels}"/>
                <c:set var ="href" value="/rhn/channels/ChannelDetail.do?cid="/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list.jspf" %>
        </tr>
        <tr class="list-row-even" id="childChannelsRow">
                <c:set var ="key" value="Child Software Channels"/>
                <c:set var ="items_list" value="${requestScope.systems.childChannels}"/>
                <c:set var ="href" value="/rhn/channels/ChannelDetail.do?cid="/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        <tr class="list-row-odd"  id="configChannelsRow">
                <c:set var ="key" value="org.config.channels.jsp"/>
                <c:set var ="items_list" value="${requestScope.systems.configChannels}"/>
                <c:set var ="href" value="/rhn/configuration/ChannelOverview.do?ccid="/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        <tr>
                <td colspan="${requestScope.systems.size + 1}"><bean:message key="softwareEntitlementDetails.header.entitlementUsage"/> &nbsp;
                         <a  id='sysEntUsageIdHide' href="javascript:pageToggleRows('sysEntUsageId', ['systemEntitlementsRow', 'softwareEntitlementsRow'])"><bean:message key="Click Here To Hide"/> </a>
                         <a  style="display:none" id='sysEntUsageIdShow' href="javascript:pageToggleRows('sysEntUsageId', ['systemEntitlementsRow', 'softwareEntitlementsRow'])"><bean:message key="Click Here To Show"/> </a>
            </td>
        </tr>
        <tr class="list-row-odd" id = "systemEntitlementsRow">
                <c:set var ="key" value="System Entitlements"/>
                <c:set var ="items_list" value="${requestScope.systems.systemEntitlements}"/>
                <c:set var ="href" value=""/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        <tr class="list-row-even" id="softwareEntitlementsRow">
                <c:set var ="key" value="Software Entitlements"/>
                <c:set var ="items_list" value="${requestScope.systems.softwareEntitlements}"/>
                <c:set var ="href" value=""/>
                <%@ include file="/WEB-INF/pages/common/fragments/systems/duplicates/render-item-list-list.jspf" %>
        </tr>
        </tbody>
</table>
</c:when>
<c:otherwise><p><bean:message key = "nosystems.message"/></p></c:otherwise>
</c:choose>
</rl:listset>

</body>
</html>
