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
</head>
<body>
<rhn:toolbar base="h1" icon="header-system" imgAlt="system.common.systemAlt"
 helpUrl="">
  <bean:message key="registeredlist.jsp.header"/>
</rhn:toolbar>

<rl:listset name="registeredSystems" legend="system">
  <rhn:csrf />
  <bean:message key="registeredlist.jsp.view"/>
  <select name="threshold" class="view-systems-registered form-control">
                <c:forEach var="option" items="${options}">
                        <c:choose>
                                <c:when test="${recentlyRegisteredSystemsForm.map.threshold eq option.value}">
                                        <option value="${option.value}" selected = "selected">${option.label}</option>
                                </c:when>
                                <c:otherwise>
                                        <option value="${option.value}">${option.label}</option>
                                </c:otherwise>
                        </c:choose>
                </c:forEach>
  </select>

  <html:submit styleClass="btn btn-default">
    <bean:message key="cloneerrata.jsp.view"/>
  </html:submit>
  <hr>
<rhn:submitted/>
        <rl:list
                dataset="pageList"
                name="systemList"
                decorator="SelectableDecorator"
                emptykey="nosystems.message"
                alphabarcolumn="name"
                filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter"
                >

                <rl:decorator name="ElaborationDecorator"/>
            <rl:decorator name="SystemIconDecorator"/>
                <rl:decorator name="PageSizeDecorator"/>

                <rl:selectablecolumn value="${current.id}"
                                                        selected="${current.selected}"
                                                        disabled="${not current.selectable}"/>
                <!--Updates Column -->
                <rl:column sortable="false"
                                   bound="false"
                           headerkey="systemlist.jsp.status"
                           styleclass="center"
                           headerclass="thin-column">
                      <c:out value="${current.statusDisplay}" escapeXml="false"/>
                </rl:column>
                <!-- Name  Column -->
                <rl:column sortable="true"
                                   bound="false"
                           headerkey="systemlist.jsp.system"
                           sortattr="name" >
                        <%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>
                </rl:column>
                <!-- Base Channel Column -->
                <rl:column sortable="true"
                                   bound="false"
                           headerkey="systemlist.jsp.channel"
                           sortattr="channelLabels" >
                        <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_list_fragment.jspf" %>
                </rl:column>

                <rl:column sortable="true"
                                   bound="false"
                           headerkey="registeredlist.jsp.date"
                           sortattr="created"
                           defaultsort="desc">
                          <rhn:formatDate humanStyle="calendar" value="${current.created}"
                             type="both" dateStyle="short" timeStyle="long"/>
                </rl:column>

                <rl:column sortable="true"
                                   bound="false"
                           headerkey="registeredlist.jsp.user"
                           sortattr="creatorName" >
                  <c:choose>
                    <c:when test="${current.creatorName != null}">
                      <rhn:icon type="header-user" title="yourrhn.jsp.user.alt" />
                      <c:out value="${current.creatorName}"/>
                    </c:when>
                    <c:otherwise>
                      <bean:message key="Unknown" />
                </c:otherwise>
              </c:choose>
                </rl:column>

                <!-- Entitlement Column -->
                <rl:column sortable="false"
                                   bound="false"
                           headerkey="systemlist.jsp.entitlement">
                      <c:out value="${current.entitlementLevel}" escapeXml="false"/>
                </rl:column>
        </rl:list>
</rl:listset>
</body>
</html>
