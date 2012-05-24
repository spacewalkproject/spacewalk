<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:choose>
  <c:when test="${showRecentlyRegisteredSystems == 'true'}">

<rl:listset name="registeredSystemsSet">
    <rhn:csrf />
	<!-- Start of active users list -->
	<rl:list dataset="recentlyRegisteredSystemsList"
	         width="100%"
	         name="systemsList"
	         title="${rhn:localize('yourrhn.jsp.recentlyregistered')}"
	         styleclass="list list-doubleheader"
	         hidepagenums="true"
	         emptykey="yourrhn.jsp.recentlyregistered.none"
	 		 >
		<rl:column bound="true"
		           headerkey="systemlist.jsp.status"
		           styleclass="first-column"
		           attr="statusDisplay"/>
		<rl:column bound="false"
		           headerkey="systemlist.jsp.system"
		           >
		<a href="/rhn/systems/details/Overview.do?sid=${current.id}">
		<c:out value="${current.serverName}"/></a>
		</rl:column>
		
		<rl:column bound="false"
		           headerkey="systemlist.jsp.channel"
		           >
			<c:choose>
	    		<c:when test="${current.channelId == null}">
	        		<bean:message key="none.message"/>
	        	</c:when>
	        	<c:otherwise>
	        		<a href="/rhn/channels/ChannelDetail.do?cid=${current.channelId}">
	        			<c:out value = "${current.channelLabels}"/>
	        		</a>
	        	</c:otherwise>
	        </c:choose>
		</rl:column>
	
		<rl:column bound="false"
		           headerkey="registeredlist.jsp.date"
		           >
			<fmt:formatDate value="${current.created}" type="both" dateStyle="short" timeStyle="long"/>
		</rl:column>
	
		<rl:column bound="false"
		           headerkey="registeredlist.jsp.user"
		           >
	          <c:choose>
	            <c:when test="${current.creatorName != null}">
	               <img src="/img/rhn-listicon-user.gif" alt="<bean:message key="yourrhn.jsp.user.alt" />"  />
	              <c:out value="${current.creatorName}"/>
	        </c:when>
		    <c:otherwise>
	              <bean:message key="Unknown" />
	            </c:otherwise>
	          </c:choose>
		</rl:column>
	
		<rl:column bound="true"
		           headerkey="systemlist.jsp.entitlement"
		           attr="entitlementLevel"
		           styleclass="last-column"/>
</rl:list>
  <span class="full-width-note-left">
  	${paginationMessage}
  </span>

  <span class="full-width-note-right">
  	<a href="/rhn/systems/Registered.do">
  		<bean:message key="yourrhn.jsp.recentlyregistered.all" />
  	</a>
  </span>

</rl:listset>

</c:when>
</c:choose>
