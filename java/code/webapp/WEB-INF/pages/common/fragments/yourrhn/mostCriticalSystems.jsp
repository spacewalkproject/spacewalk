<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<rl:listset name="rhnListSet">
	<rl:list
		dataset="mostCriticalList"
		name="criticalSystems"
		emptykey="yourrhn.jsp.criticalsystems.none"
		styleId="most-critical-systems"
		styleclass="list list-doubleheader"
		hidepagenums="true"
		title="${rhn:localize('yourrhn.jsp.criticalsystems')}"
		>
		
		<rl:column
			headerkey="probesuitesystemsedit.jsp.systemname"
			headerclass="row-2"
			styleclass="first-column">
			<a href="/rhn/systems/details/Overview.do?sid=${current.id}">
			<c:out value="${current.serverName}"/></a>
		</rl:column>
	
		<rl:column headerkey="yourrhn.jsp.allupdates"
    				headerclass="row-2">
    		${current.securityErrata + current.bugErrata + current.enhancementErrata}	
    	</rl:column>
		
		<%@ include file="/WEB-INF/pages/common/fragments/systems/monitoring_status_systems.jspf" %>
		
   		<rl:column headerkey="yourrhn.jsp.criticalsystems.securityerrata"
    			headerclass="row-2 text-align: center;">
   			<img src="/img/wrh-security.gif" alt="<bean:message key="errata-legend.jsp.security"/>" />${current.securityErrata}		
    	</rl:column>

    	<rl:column headerkey="yourrhn.jsp.criticalsystems.bugfixerrata"
    			headerclass="row-2 text-align: center;">
   			<img src="/img/wrh-bug.gif" alt="<bean:message key="errata-legend.jsp.bugfix"/>" />${current.bugErrata}		
    	</rl:column>

    	<rl:column headerkey="yourrhn.jsp.criticalsystems.enhancementerrata"
    			headerclass="row-2 text-align: center;"
    			styleclass="last-column">
   			<img src="/img/rhn-icon-enhancement.gif" alt="<bean:message key="errata-legend.jsp.enhancement"/>" />${current.enhancementErrata}		
    	</rl:column>

	</rl:list>
	
	<span class="full-width-note-left">
		${paginationMessage}
	</span>
	
	<span class="full-width-note-right">
  		<a href="/rhn/systems/OutOfDate.do">
  			<bean:message key="yourrhn.jsp.allcriticalsystems" />
  		</a>
  	</span>
</rl:listset>



