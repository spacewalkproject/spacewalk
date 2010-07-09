<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
    <bean:message key="basesub.jsp.header" />
  </h2>

  <div class="page-summary">
    <bean:message key="basesub.jsp.summary"/>
  </div>

  <rl:listset name="baselist">
    <html:hidden property="submitted" value="true"/>

	<!-- Start of active users list -->
	<rl:list dataset="baselist"
         width="100%"
         name="baselist"
         styleclass="list"
         emptykey="basesub.jsp.noSystems">

	<rl:column bound="false"
	           sortable="true"
	           headerkey="basesub.jsp.channelname"
	           styleclass="first-column"
	           sortattr="name"
	           >
	    <c:if test="${current.id > 0}">
          <c:out value="<a href=\"/rhn/channels/ChannelDetail.do?cid=${current.id}\">${current.name}</a>" escapeXml="false" />
	    </c:if>
	    <c:if test="${current.id <= 0}">
          <c:out value="${current.name}" escapeXml="false" />
	    </c:if>
    </rl:column>

    <rl:column bound="false"
	           sortable="false"
	           headerkey="basesub.jsp.systemCount">
	    <c:if test="${current.id > 0}">
          <a href="/rhn/channels/ChannelSubscribers.do?cid=${current.id}">${current.systemCount}</a>
	    </c:if>
	    <c:if test="${current.id <= 0}">
          ${current.systemCount}
	    </c:if>
    </rl:column>

    <rl:column bound="false"
	           sortable="false"
	           headerkey="basesub.jsp.options"
	           styleclass="last-column">
        <select name="base-for-${current.id}" size="5">
        	<option value="__no_change__" selected><bean:message key="basesub.jsp.no-channel-change"/></option>
        	<c:if test="${not empty current.allowedCustomChannels}">
        	  <optgroup label='<bean:message key="basesub.jsp.rhn-channels"/>' />
        	</c:if>
            <option value="-1"><bean:message key="basesub.jsp.default-channel"/></option>
        	  <c:forEach items="${current.allowedBaseChannels}" var="chan">
        		<option value="${chan.id}"><c:out value="${chan.name}" /></option>
        	  </c:forEach>
        	<c:if test="${not empty current.allowedCustomChannels}">
        	  </optgroup>
        	</c:if>
        	<c:if test="${not empty current.allowedCustomChannels}">
        	  <optgroup label='<bean:message key="basesub.jsp.custom-channels"/>' />
        	  <c:forEach items="${current.allowedCustomChannels}" var="chan">
        		<option value="${chan.id}"><c:out value="${chan.name}" /></option>
        	  </c:forEach>
        	  </optgroup>
        	</c:if>
        </select>
    </rl:column>

  	</rl:list>
	<hr />
	<div align="right"><html:submit property="dispatch"><bean:message key="basesub.jsp.confirmSubscriptions"/></html:submit></div>
  </rl:listset>
</body>
</html>
