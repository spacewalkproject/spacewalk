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

        <rl:listset name="errataListSet" legend="errata">
            <rhn:csrf />
            <rhn:submitted />
            <rl:list name="errataList" styleclass="list"
                     emptykey="erratalist.jsp.norelevanterrata" alphabarcolumn="advisorySynopsis">
                <rl:decorator name="ElaborationDecorator"/>
                <rl:decorator name="PageSizeDecorator"/>
                <rl:decorator name="SelectableDecorator"/>

                <rl:selectablecolumn value="${current.id}" selected="${current.selected}"
                                     disabled="${not current.selectable}" styleclass="first-column"/>

                <rl:column headerkey="erratalist.jsp.type" styleclass="text-align: center;" bound="false">
                    <c:if test="${current.securityAdvisory}">
                        <rhn:icon type="errata-security" />
                    </c:if>
                    <c:if test="${current.bugFix}">
                        <rhn:icon type="errata-bugfix" />
                    </c:if>
                    <c:if test="${current.productEnhancement}">
                        <rhn:icon type="errata-enhance" />
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
                    <a href="/rhn/systems/ssm/ErrataSystemsAffected.do?eid=${current.id}">${current.affectedSystemCount}</a>
                </rl:column>

                <rl:column headerkey="erratalist.jsp.updated" bound="false" sortattr="updateDateObj"
                           sortable="true" defaultsort="desc" styleclass="last-column">
                    ${current.updateDate}
                </rl:column>

            </rl:list>

            <div class="text-right">
                <hr />
                <html:submit property="dispatch">
                    <bean:message key="errata.jsp.apply"/>
                </html:submit>
            </div>
            <rhn:submitted/>
        </rl:listset>
    </body>
</html>
