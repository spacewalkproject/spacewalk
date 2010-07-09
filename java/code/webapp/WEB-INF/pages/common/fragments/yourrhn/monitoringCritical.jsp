<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
  <c:when test="${requestScope.criticalReflinkkeyarg0 != null}">
	<div class="full-width-wrapper" style="clear: both;" id="critical-probes-pane">
		<rl:listset name="criticalProbesSet">
			<rl:list dataset="monitoringCriticalList"
	    		     name="criticalProbes"
	         		 styleclass="list"
	         		 hidepagenums="true"
	         		 emptykey="yourrhn.jsp.nocriticalprobes"
             		 reflink="/rhn/monitoring/ProbeList.do?state=CRITICAL"
             		 reflinkkey="yourrhn.jsp.allcriticalprobes"
             		 reflinkkeyarg0="${requestScope.criticalReflinkkeyarg0}">
				<rl:column headerkey="yourrhn.jsp.criticalprobes"
		           	styleclass="first-column">
		    		<img src="/img/rhn-mon-down.gif"/>
    				<c:out value="${current.description}"/>
				</rl:column>
				<rl:column headerkey="yourrhn.jsp.systems"
		           	styleclass="last-column">
					<c:out value="${current.probeCount}"/>
				</rl:column>
  			</rl:list>
		</rl:listset>
	</div>
  </c:when>
</c:choose>