<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c-rt" %>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="system.common.systemAlt">
  <bean:message key="systemcurrency.jsp.header"/>
</rhn:toolbar>

<rl:listset name="registeredSystems" legend="system">

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
		           styleclass="first-column"
                           sortattr="name" >
		    <img src="/img/rhn-listicon-system.gif" alt="<bean:message key="systemlist.jsp.nonvirt"/>" />
                    <c:out value="<a href=\"/rhn/systems/details/Overview.do?sid=${current.id}\">"  escapeXml="false" />
		    <c:choose>
                        <c:when test="${empty current.name}">
			<bean:message key="sdc.details.overview.unknown"/>
                        </c:when>
                        <c:otherwise>
                            <c:out value="${current.name}</a>" escapeXml="false" />
                        </c:otherwise>
                    </c:choose>
                </rl:column>

		<!-- Critical Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.critical"
		           sortattr="created"
		           defaultsort="desc">
                           <c:choose>
                               <c:when test="${current.critical >= 10}">
                               <font color="red">
                               </c:when>
                               <c:when test="${current.critical >= 5}">
                               <font color="orange">
                               </c:when>
                           </c:choose>
			       ${current.critical}
                           <c:choose>
                               <c:when test="${current.critical >= 5}">
                               </font>
                               </c:when>
                           </c:choose>
		</rl:column>
		<!-- Important Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.important"
		           sortattr="created"
		           defaultsort="desc">
                           <c:choose>
                               <c:when test="${current.important >= 15}">
                               <font color="red">
                               </c:when>
                               <c:when test="${current.important >= 10}">
                               <font color="orange">
                               </c:when>
                           </c:choose>
                               ${current.important}
                           <c:choose>
                               <c:when test="${current.important >= 10}">
                               </font>
                               </c:when>
                           </c:choose>
		</rl:column>
		<!-- Moderate Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.moderate"
		           sortattr="created"
		           defaultsort="desc">
                           <c:choose>
                               <c:when test="${current.moderate >= 20}">
                               <font color="red">
                               </c:when>
                               <c:when test="${current.moderate >= 15}">
                               <font color="orange">
                               </c:when>
                           </c:choose>
                               ${current.moderate}
                           <c:choose>
                               <c:when test="${current.moderate >= 15}">
                               </font>
                               </c:when>
                           </c:choose>
		</rl:column>
		<!-- Low Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.low"
		           sortattr="created"
		           defaultsort="desc">
                           <c:choose>
                               <c:when test="${current.low >= 25}">
                               <font color="red">
                               </c:when>
                               <c:when test="${current.low >= 20}">
                               <font color="orange">
                               </c:when>
                           </c:choose>
			      ${current.low}
                           <c:choose>
                               <c:when test="${current.low >= 20}">
                               </font>
                               </c:when>
                           </c:choose>
		</rl:column>
		<!-- Bugfix Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.bug"
		           sortattr="created"
		           defaultsort="desc">
			  ${current.bug}
		</rl:column>
		<!-- Enhancement Errata Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.enhancement"
		           sortattr="created"
		           defaultsort="desc">
			  ${current.enhancement}
		</rl:column>
		<!-- Score Column -->
		<rl:column sortable="true"
				   bound="false"
		           headerkey="systemcurrency.jsp.score"
		           sortattr="created"
                           styleclass="last-column"
		           defaultsort="desc">
                           <c:out value="${current.enhancement +
				current.bug * 2 +
				current.low * 4 +
				current.moderate * 8 +
				current.important * 16 +
				current.critical * 32}"/>
		</rl:column>
	</rl:list>
</rl:listset>
</body>
</html>
