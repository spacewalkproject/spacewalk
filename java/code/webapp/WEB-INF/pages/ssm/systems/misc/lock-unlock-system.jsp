<%--
    Document   : lock-unlock-system
    Created on : Aug 1, 2013, 3:50:55 PM
    Author     : bo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html:xhtml/>
<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2><bean:message key="ssm.misc.lockunlock.header" /></h2>
        <p><bean:message key="ssm.misc.lockunlock.summary" /></p>

        <rl:listset name="systemsListSet" legend="system">
            <table class="table">
                <tbody>
                    <tr>
                        <th><label for="lock-reason">Lock reason:</label></th>
                        <td><input type="text" id="lock-reason" name="lock_reason" value="" style="width: 100%;" onkeypress="return event.keyCode != 13;" /></td>
                    </tr>
                </tbody>
            </table>
            <rhn:csrf />
            <rhn:submitted />
            <rl:list width="100%"
                     dataset="pageList"
                     name="systemList"
                     styleclass="list"
                     alphabarcolumn="name">
                <rl:decorator name="ElaborationDecorator"/>
                <rl:decorator name="PageSizeDecorator"/>
                <rl:decorator name="SelectableDecorator"/>

                <rl:selectablecolumn value="${current.id}"
                                     selected="${current.selected}"
                                     disabled="${not current.selectable}"
                                     styleclass="first-column"/>
                <rl:column headerkey="systemlist.jsp.system" bound="false" sortattr="name" sortable="true">
                    <c:choose>
                        <c:when test="${current.locked > 0}">
                            <img src="/img/icon_locked.gif"/>
                            <a href="/rhn/systems/table/Overview.do?sid=${current.id}">${current.name}</a>
                        </c:when>
                        <c:otherwise>
                            <%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>
                        </c:otherwise>
                    </c:choose>
                </rl:column>
                <rl:column headerkey="systemlist.jsp.channel" bound="false" sortattr="name" sortable="true" styleclass="last-column">
                    <a href="/rhn/channels/ChannelDetail.do?cid=${current.channelId}">${current.channelLabels}</a>
                </rl:column>
                <rl:column headerkey="systemlist.jsp.entitlement" bound="false" sortattr="name" sortable="true" styleclass="last-column">
                    <c:choose>
                        <c:when test="${!empty current.addOnEntitlementLevel}">
                            ${current.baseEntitlementLevel}, ${current.addOnEntitlementLevel}
                        </c:when>
                        <c:otherwise>
                            ${current.baseEntitlementLevel}
                        </c:otherwise>
                    </c:choose>
                </rl:column>
            </rl:list>
            <div align="right">
                <input type="submit" name="dispatch" value='<bean:message key="ssm.misc.lockunlock.dispatch.lock"/>'/>
                <input type="submit" name="dispatch" value='<bean:message key="ssm.misc.lockunlock.dispatch.unlock"/>'/>
            </div>
        </rl:listset>
    </body>
</html>
