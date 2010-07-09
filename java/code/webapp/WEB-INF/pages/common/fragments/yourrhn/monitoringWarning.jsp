<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
  <c:when test="${requestScope.warningReflinkkeyarg0 != null}">
	<div class="full-width-wrapper" style="clear: both;" id="warning-probes-pane">
	 	<rl:listset name="warningProbesSet">
			<rl:list dataset="monitoringWarningList"
	    		     name="warningProbes"
	         		 styleclass="list"
	         		 hidepagenums="true"
	         		 emptykey="yourrhn.jsp.nowarningprobes"
             		 reflink="/rhn/monitoring/ProbeList.do?state=WARNING"
             		 reflinkkey="yourrhn.jsp.allwarningprobes"
             		 reflinkkeyarg0="${requestScope.warningReflinkkeyarg0}">
				<rl:column headerkey="yourrhn.jsp.warningprobes"
		           	styleclass="first-column">
		    		<img src="/img/rhn-mon-warning.gif"/>
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