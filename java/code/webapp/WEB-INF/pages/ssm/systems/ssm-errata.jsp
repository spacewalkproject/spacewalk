<%--
    Document   : ssm-errata
    Created on : Aug 22, 2013, 1:18:24 PM
    Author     : Bo Maryniuk
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ page import="com.redhat.rhn.frontend.action.ssm.ErrataListAction" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">


<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2><bean:message key="ssm.patches.list.header" /></h2>
        <p><bean:message key="ssm.patches.list.summary" /></p>

        <c:choose>
        <c:when test="${empty param.afs}">
        <rl:listset name="errataListSet" legend="errata">
            <rhn:csrf />
            <rhn:submitted />
            <rl:list width="100%" name="summaryList" styleclass="list"
                     emptykey="erratalist.jsp.norelevanterrata" alphabarcolumn="advisorySynopsis">
                <rl:decorator name="ElaborationDecorator"/>
                <rl:decorator name="PageSizeDecorator"/>
                <rl:decorator name="SelectableDecorator"/>

                <rl:selectablecolumn value="${current.id}" selected="${current.selected}"
                                     disabled="${not current.selectable}" styleclass="first-column"/>

                <rl:column headerkey="erratalist.jsp.type" styleclass="text-align: center;" bound="false">
                    <c:if test="${current.securityAdvisory}">
                        <img src="/img/wrh-security.gif" title="<bean:message key="erratalist.jsp.securityadvisory"/>" />
                    </c:if>
                    <c:if test="${current.bugFix}">
                        <img src="/img/wrh-bug.gif" title="<bean:message key="erratalist.jsp.bugadvisory"/>" />
                    </c:if>
                    <c:if test="${current.productEnhancement}">
                        <img src="/img/wrh-product.gif" title="<bean:message key="erratalist.jsp.productenhancementadvisory"/>" />
                    </c:if>
                </rl:column>

                <rl:column headerkey="erratalist.jsp.advisory" bound="false" sortattr="advisoryName" sortable="true">
                    <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
                </rl:column>

                <rl:column headerkey="erratalist.jsp.synopsis" bound="false" sortattr="advisorySynopsis"
                           sortable="true" filterattr="advisorySynopsis">
                    ${current.advisorySynopsis}
                </rl:column>

                <rl:column headerkey="errata.jsp.status" bound="false" sortattr="currentStatusAndActionId[0]" sortable="true">
                    <c:if test="${not empty current.status}">
                        <c:if test="${current.currentStatusAndActionId[0] == 'Queued'}">
                            <a href="/rhn/schedule/ActionDetails.do?aid=${current.currentStatusAndActionId[1]}">
                                <bean:message key="affectedsystems.jsp.pending"/>
                            </a>
                        </c:if>
                        <c:if test="${current.currentStatusAndActionId[0] == 'Failed'}">
                            <a href="/network/systems/details/history/event.pxt?sid=${param.sid}&hid=${current.currentStatusAndActionId[1]}">
                                <bean:message key="actions.jsp.failed"/>
                            </a>
                        </c:if>
                        <c:if test="${current.currentStatusAndActionId[0] == 'Picked Up'}">
                            <a href="/network/systems/details/history/event.pxt?sid=${param.sid}&hid=${current.currentStatusAndActionId[1]}">
                                <bean:message key="actions.jsp.pickedup"/>
                            </a>
                        </c:if>
                    </c:if>
                    <c:if test="${empty current.status}">
                        <bean:message key="affectedsystems.jsp.none"/>
                    </c:if>
                </rl:column>

                <rl:column headerkey="errata.jsp.affected" bound="false" sortattr="affectedSystemCount" sortable="true">
                    <a href="/rhn/systems/ssm/ListPatches.do?<%=ErrataListAction.RP_AFFECTED_SYSTEMS%>=${current.id}">${current.affectedSystemCount}</a>
                </rl:column>

                <rl:column headerkey="erratalist.jsp.updated" bound="false" sortattr="updateDateObj"
                           sortable="true" defaultsort="desc" styleclass="last-column">
                    ${current.updateDate}
                </rl:column>

            </rl:list>

            <div align="left">
                <!--
                <p><bean:message key="installconfirm.jsp.widgetsummary"/></p>
                -->
                <table class="details" align="center">
                    <tr>
                        <th><label for="radio_use_date_now"><bean:message key="scheduleremote.jsp.nosoonerthan"/></label></th>
                        <td>
                            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                <jsp:param name="widget" value="date"/>
                            </jsp:include><br/>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="text-right">
                <hr />
                <html:submit property="dispatch">
                    <bean:message key="errata.jsp.apply"/>
                </html:submit>
            </div>
            <rhn:submitted/>
        </rl:listset>
        </c:when>
            <c:otherwise>
                <rl:listset name="groupSet" legend="system">
                    <rhn:csrf />
                    <rl:list dataset="detailsList" width="100%" name="detailsList"
                             styleclass="list" emptykey="ssm.operations.actionchaindetails.table.empty">
                        <rl:decorator name="PageSizeDecorator"/>
                        <rl:column headerkey="systemlist.jsp.system" bound="false" sortattr="advisoryName" sortable="true">
                            <a href="/rhn/systems/details/Overview.do?sid=${current.id}">${current.name}</a>
                        </rl:column>
                        <rl:column headerkey="ssm.overview.errata" bound="false" sortattr="advisoryName" sortable="true">
                            <a href="/rhn/systems/details/ErrataList.do?sid=${current.id}">${current.totalErrataCount}</a>
                        </rl:column>
                        <rl:column headerkey="ssm.overview.packages" bound="false" sortattr="advisoryName" sortable="true">
                            <a href="/rhn/systems/details/packages/UpgradableList.do?sid=${current.id}">${current.pendingUpdates}</a>
                        </rl:column>
                        <rl:column sortable="false" bound="false" headerkey="systemlist.jsp.channel"  >
                            <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_list_fragment.jspf" %>
                        </rl:column>
                        <rl:column sortable="false" bound="false" headerkey="systemlist.jsp.entitlement">
                            <c:out value="${current.entitlementLevel}" escapeXml="false"/>
                        </rl:column>
                    </rl:list>
                </rl:listset>

                <html:form action="/systems/ssm/ListPatches">
                    <rhn:csrf />
                    <div class="text-right">
                        <hr/>
                        <input type="submit" name="back" value="<bean:message key="ssm.errata.serverlist.return"/>" />
                    </div>
                </html:form>
            </c:otherwise>
        </c:choose>
    </body>
</html>
