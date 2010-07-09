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
  <bean:message key="ssmchildsubconfirm.jsp.header" />
</h2>

  <div class="page-summary">
    <p>
    <bean:message key="ssmchildsubconfirm.jsp.summary"/>
    </p>
  </div>

  <rl:listset name="channelchanges">
    <html:hidden property="submitted" value="true"/>
	<!-- Start of active users list -->
	<rl:list
         width="100%"

         styleclass="list"
         emptykey="ssmchildsubconfirm.jsp.noSystems">

    <!-- system name -->
	<rl:column bound="false"
	           sortable="true"
	           headerkey="ssmchildsubconfirm.jsp.systemName"
	           styleclass="first-column"
               attr="name">
		<c:out value="<a href=\"/rhn/systems/details/Overview.do?sid=${current.id}\">${current.name}</a>" escapeXml="false" />
	</rl:column>
	
	<!-- Channels we're allowed to subscribe to -->
	<rl:column bound="false"
	           sortable="false"
	           headerkey="ssmchildsubconfirm.jsp.canSub">
	  <c:forEach items="${current.subscribeNames}" var="chan">
	  	<c:out value="${chan}" /><br />
	  </c:forEach>
	</rl:column>
	
	<!--  Channels we're allowed to unsubscribe from -->
	<rl:column bound="false"
			   sortable="false"
	           headerkey="ssmchildsubconfirm.jsp.canUnsub"
	           styleclass="last-column">
	  <c:forEach items="${current.unsubcribeNames}" var="chan">
	  	<c:out value="${chan}" /><br />
	  </c:forEach>
	</rl:column>

	</rl:list>
	<hr />
	<div align="right"><html:submit property="dispatch"><bean:message key="ssmchildsubconfirm.jsp.submit"/></html:submit></div>
  </rl:listset>
</body>
</html>
