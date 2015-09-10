<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="name" value="Systems Affected" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/errata/errata-header.jspf" %>
<h2>
  <rhn:icon type="header-system-physical" title="system.common.systemAlt" />
  <bean:message key="affectedsystems.jsp.header"/>
</h2>

  <div class="page-summary">
    <p>
    <bean:message key="affectedsystems.jsp.summary"/>
    <bean:message key="affectedsystems.jsp.summarywithacl"/>
    </p>
  </div>

        <rl:listset name="systemAffectedListSet">
        <rhn:csrf />

                <rl:list
                        dataset="pageList"
                        name="systemAffectedList"
                        emptykey="nosystems.message"
                        alphabarcolumn="name"
                        filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter">

                        <rl:decorator name="ElaborationDecorator"/>
                        <rl:decorator name="SelectableDecorator"/>
                        <rl:decorator name="PageSizeDecorator"/>
                        <rl:decorator name="AddToSsmDecorator"/>

                        <rl:selectablecolumn value="${current.id}"
                                selected="${current.selected}"
                                disabled="${not current.selectable}"/>
                        <rl:column sortable="true"
                                bound="false"
                                headerkey="actions.jsp.system"
                                sortattr="name">
                <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
                  <c:out value="${current.name}" escapeXml="true"/>
                </a>
                        </rl:column>
                        <rl:column sortable="false"
                                bound="false"
                        headerkey="affectedsystems.jsp.status">
                        <c:if test="${not empty current.status}">
                                <c:if test="${current.currentStatusAndActionId[0] == 'Queued'}">
                                                <a href="/rhn/schedule/ActionDetails.do?aid=${current.currentStatusAndActionId[1]}">
                                                <bean:message key="affectedsystems.jsp.pending"/></a>
                                </c:if>
                                <c:if test="${current.currentStatusAndActionId[0] == 'Failed'}">
                                                <a href="/rhn/schedule/ActionDetails.do?aid=${current.currentStatusAndActionId[1]}">
                                                <bean:message key="actions.jsp.failed"/></a>
                                </c:if>
                        </c:if>
                                <c:if test="${empty current.status}">
                        <bean:message key="affectedsystems.jsp.none"/>
                        </c:if>
                        </rl:column>
                        <rl:column sortable="true"
                                bound="false"
                        headerkey="actions.jsp.basechannel"
                        sortattr="channelLabels">
                                ${current.channelLabels}
                        </rl:column>
                        <rl:column sortable="true"
                                bound="false"
                        headerkey="affectedsystems.jsp.entitle"
                        sortattr="entitlementLevel">
                        ${current.entitlementLevel}
                        </rl:column>
                </rl:list>

                <div class="text-right">
                <hr />
                <html:submit styleClass="btn btn-default" property="dispatch">
                        <bean:message key="affectedsystems.jsp.apply"/>
                </html:submit>
                </div>

                <rl:csv dataset="pageList"
                        name="systemAffectedCSVExport"
                        exportColumns="name, status, channelLabels, entitlementLevel"
                        header="${errata.advisoryName} - ${errata.advisoryType}" />

                        <rhn:submitted/>
        </rl:listset>

</body>
</html>
