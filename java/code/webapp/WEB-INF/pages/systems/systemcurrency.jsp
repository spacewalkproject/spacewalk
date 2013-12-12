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
<rhn:toolbar base="h1" icon="header-system" imgAlt="system.common.systemAlt">
  <bean:message key="systemcurrency.jsp.header"/>
</rhn:toolbar>

<rl:listset name="registeredSystems" legend="system">
<rhn:csrf />
<rhn:submitted />

<div class="full-width-wrapper" style="clear: both;">
	<rl:list
		dataset="pageList"
		name="systemCurrencyList"
		decorator="SelectableDecorator"
		emptykey="nosystems.message"
		alphabarcolumn="name"
		filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemCurrencyFilter"
		>

	    <rl:decorator name="SystemCurrencyIconDecorator"/>
		<rl:decorator name="PageSizeDecorator"/>

                <!-- System Name Column -->
                <rl:column sortable="true"
                           bound="false"
                           headerkey="systemlist.jsp.system"
                           sortattr="name" >
		    <rhn:icon type="header-system-physical" title="<bean:message key='systemlist.jsp.nonvirt' />" />
                    <c:out value="<a href=\"/rhn/systems/details/Overview.do?sid=${current.id}\">"  escapeXml="false" />
		    <c:choose>
                        <c:when test="${empty current.name}">
			<bean:message key="sdc.details.overview.unknown"/>
                        </c:when>
                        <c:otherwise>
                            <c:out value="${current.name}" escapeXml="true" />
                        </c:otherwise>
                    </c:choose>
                </rl:column>

		<!-- Critical Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.critical"
		           sortattr="critical">
                           <c:choose>
                             <c:when test="${current.critical > 0}">
                               <a href="/rhn/systems/details/ErrataList.do?sid=${current.id}&type=${rhn:localize('errata.create.securityadvisory.crit')}">${current.critical}</a>
                             </c:when>
                             <c:otherwise>
                               ${current.critical}
                             </c:otherwise>
                           </c:choose>
                           <c:choose>
                             <c:when test="${current.critical >= 10}">
                               <rhn:icon type="system-crit" />
                             </c:when>
                             <c:when test="${current.critical >= 5}">
                               <rhn:icon type="system-warn" />
                             </c:when>
                           </c:choose>
		</rl:column>
		<!-- Important Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.important"
		           sortattr="important">
                           <c:choose>
                             <c:when test="${current.important > 0}">
                               <a href="/rhn/systems/details/ErrataList.do?sid=${current.id}&type=${rhn:localize('errata.create.securityadvisory.imp')}">${current.important}</a>
                             </c:when>
                             <c:otherwise>
                               ${current.important}
                             </c:otherwise>
                           </c:choose>
                           <c:choose>
                             <c:when test="${current.important >= 15}">
                               <rhn:icon type="system-crit" />
                             </c:when>
                             <c:when test="${current.important >= 10}">
                               <rhn:icon type="system-warn" />
                             </c:when>
                           </c:choose>
		</rl:column>
		<!-- Moderate Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.moderate"
		           sortattr="moderate">
                           <c:choose>
                             <c:when test="${current.moderate > 0}">
                               <a href="/rhn/systems/details/ErrataList.do?sid=${current.id}&type=${rhn:localize('errata.create.securityadvisory.mod')}">${current.moderate}</a>
                             </c:when>
                             <c:otherwise>
                               ${current.moderate}
                             </c:otherwise>
                           </c:choose>
                           <c:choose>
                             <c:when test="${current.moderate >= 20}">
                               <rhn:icon type="system-crit" />
                             </c:when>
                             <c:when test="${current.moderate >= 15}">
                               <rhn:icon type="system-warn" />
                             </c:when>
                           </c:choose>
		</rl:column>
		<!-- Low Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.low"
		           sortattr="low">
                           <c:choose>
                             <c:when test="${current.low > 0}">
                               <a href="/rhn/systems/details/ErrataList.do?sid=${current.id}&type=${rhn:localize('errata.create.securityadvisory.low')}">${current.low}</a>
                             </c:when>
                             <c:otherwise>
                               ${current.low}
                             </c:otherwise>
                           </c:choose>
                           <c:choose>
                             <c:when test="${current.low >= 25}">
                               <rhn:icon type="system-crit" />
                             </c:when>
                             <c:when test="${current.low >= 20}">
                               <rhn:icon type="system-warn" />
                             </c:when>
                           </c:choose>
		</rl:column>
		<!-- Bugfix Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.bug"
		           sortattr="bug">
                           <c:choose>
                             <c:when test="${current.bug > 0}">
                               <a href="/rhn/systems/details/ErrataList.do?sid=${current.id}&type=${rhn:localize('errata.create.bugfixadvisory')}">${current.bug}</a>
                             </c:when>
                             <c:otherwise>
                               ${current.bug}
                             </c:otherwise>
                           </c:choose>
		</rl:column>
		<!-- Enhancement Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.enhancement"
		           sortattr="enhancement">
                           <c:choose>
                             <c:when test="${current.enhancement > 0}">
                               <a href="/rhn/systems/details/ErrataList.do?sid=${current.id}&type=${rhn:localize('errata.create.productenhancementadvisory')}">${current.enhancement}</a>
                             </c:when>
                             <c:otherwise>
                               ${current.enhancement}
                             </c:otherwise>
                           </c:choose>
		</rl:column>
		<!-- Score Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.score"
		           sortattr="score"
		           defaultsort="desc">
                           <c:out value="${current.score}" />
		</rl:column>
	</rl:list>
    <rl:csv dataset="pageList" name="systemCurrencyList"
        exportColumns="id, serverName, critical, important, moderate, low, bug, enhancement, score" />
</rl:listset>
</body>
</html>
