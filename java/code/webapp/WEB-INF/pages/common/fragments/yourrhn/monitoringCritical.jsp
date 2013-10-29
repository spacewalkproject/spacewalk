<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
  <c:when test="${requestScope.criticalReflinkkeyarg0 != null}">
	<div id="critical-probes-pane">
		<rl:listset name="criticalProbesSet">
            <rhn:csrf />
			<rl:list dataset="monitoringCriticalList"
	    		     name="criticalProbes"
	         		 styleclass="list"
	         		 hidepagenums="true"
	         		 emptykey="yourrhn.jsp.nocriticalprobes"
             		 reflink="/rhn/monitoring/ProbeList.do?state=CRITICAL"
             		 reflinkkey="yourrhn.jsp.allcriticalprobes"
             		 reflinkkeyarg0="${requestScope.criticalReflinkkeyarg0}">
				<rl:column headerkey="yourrhn.jsp.criticalprobes">
		    		<img src="/img/rhn-mon-down.gif"/>
    				<c:out value="${current.description}"/>
				</rl:column>
				<rl:column headerkey="yourrhn.jsp.systems">
					<c:out value="${current.probeCount}"/>
				</rl:column>
  			</rl:list>
		</rl:listset>
	</div>
  </c:when>
</c:choose>
